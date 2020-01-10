/*--------------------------------------------------------------------------------------------
 *  Copyright (c) Fantaisie Software. All rights reserved.
 *  Dual licensed under the GPL and Fantaisie Software licenses.
 *  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
 *--------------------------------------------------------------------------------------------
 *
 *  Support functions for Debugger network communication
 *
 *
 *  Note:
 *    The Winsock lib is source compatible with POSIX (mostly), but not binary compatible.
 *    For example the fd_set structure and FD_SET, FD_CLR etc macros are present but
 *    implemented differently on Windows, Linux and Mac so implementing these (rather complex)
 *    macros in PB code for every OS is rather messy.
 *
 *    So we just have the network support functions in this C file and import it in PB.
 *
 *    We can't just use the PB network lib because it uses non-blocking sockets, also it won't
 *    work for receiving a thread because the IDE and Debugger are not compiled threadsafe.
 *
 *  Note:
 *    This code needs the Memory lib for calling PB_AllocateMemory(), but it will be linked anyway
 *    as the IDE/debugger use it all the time.
 */


// Include the DebuggerInternal.h so we get all the debugger's socket stuff
// Note: need to add the $PB_LIBRARIES to the include path in the makefile
//
#include <Debugger/DebuggerInternal.h>


// Wrappers for the simple stuff for consistency
//
integer Network_Initialize()
{
  return OS_InitNetwork();
}

// returns new Socket or SOCKET_ERROR
OS_SOCKETTYPE Network_CreateSocket()
{
  return socket(AF_INET, SOCK_STREAM, 0);
}

void Network_CloseSocket(OS_SOCKETTYPE Socket)
{
  OS_CloseSocket(Socket);
}


// Only initiates the connect.
// Use Network_ConnectSocketCheck() to wait for a connection/failure.
// Returns 0 on failure
//
integer Network_ConnectSocketStart(OS_SOCKETTYPE Socket, char *Hostname, int Port)
{
  struct hostent *Host;
  struct sockaddr_in ClientHost;
  int Address;
  int NonBlock = 1;
  int Result = 0;

  if ((Port >= 0) && (Port < 65536))
  {
    // set the socket to non-blocking for the connect (so we can poll the status with select())
    //
    OS_IOCTLSocket(Socket, FIONBIO, &NonBlock);

    Address = inet_addr(Hostname);

    if (Address == INADDR_NONE)
    {
      if (Host = gethostbyname(Hostname))
      {
        Address = *(int *)(Host->h_addr_list[0]);
      }
    }

    if (Address != INADDR_NONE)
    {
      ClientHost.sin_family = AF_INET;
      ClientHost.sin_port   = htons(Port);
      ClientHost.sin_addr.s_addr = Address;

      if (connect(Socket, (struct sockaddr *)&ClientHost, sizeof(ClientHost)) == 0)
      {
        Result = 1;
      }
      else
      {
        // Check if we had an error or if we just need to check for completion later
        //
        #ifdef WINDOWS
          if (WSAGetLastError() == WSAEWOULDBLOCK)
            Result = 1;
        #else
          if (errno == EINPROGRESS)
            Result = 1;
        #endif
      }
    }
  }

  return Result;
}



// Check the status of a connect()
//
// Returns:
//   0 = still pending
//   1 = connected
//   2 = connection failed
//
integer Network_ConnectSocketCheck(OS_SOCKETTYPE Socket)
{
  fd_set list1, list2;
  int nfds;
  int result;
  int NonBlock = 0;
  int Size;
  struct timeval timeout = {0, 0};
  struct linger lingeropt = {1, 10}; // timeout in seconds

  #ifdef WINDOWS
    BOOL error;
  #else
    int error;
  #endif

  // for the write parameter (will get signaled if connection succeeded)
  FD_ZERO(&list1);
  FD_SET(Socket, &list1);

  // for the exception parameter (will get signaled if connection failed)
  FD_ZERO(&list2);
  FD_SET(Socket, &list2);

  // The nfds must be the highest FD in the set+1, but on Windows, Socket is an opaque type (and nfds is ignored)
  #ifdef WINDOWS
    nfds = 0;
  #else
    nfds = Socket+1;
  #endif

  result = select(nfds, NULL, &list1, &list2, &timeout);

  if (result < 0)
  {
    return 2;
  }
  else if (result == 0)
  {
    return 0;
  }
  else
  {
    // Need to check if it is a connect or connect fail
    Size = sizeof(error);

    if (getsockopt(Socket, SOL_SOCKET, SO_ERROR, (void *)&error, &Size) != -1)
    {
      if (error)
      {
        // connection failed
        return 2;
      }
      else
      {
        // set the socket back to blocking mode
        OS_IOCTLSocket(Socket, FIONBIO, &NonBlock);

        // set the linger option so remaining data is sent when closing the socket
        setsockopt(Socket, SOL_SOCKET, SO_LINGER, (void *)&lingeropt, sizeof(lingeropt));

        return 1;
      }
    }
    else
    {
      return 2;
    }
  }
}

// Put the socket in listen mode (1 connection max)
// If Interface is empty, bind to all interfaces
//
integer Network_Listen(OS_SOCKETTYPE Socket, char *Interface, int Port)
{
  struct sockaddr_in service;
  int Address;
  struct hostent *Host;

  if (Interface && *Interface)
  {
    Address = inet_addr(Interface);

    if (Address == INADDR_NONE)
    {
      if (Host = gethostbyname(Interface))
      {
        Address = *(int *)(Host->h_addr_list[0]);
      }
    }
  }
  else
  {
    Address = INADDR_ANY;
  }

  if (Address != INADDR_NONE)
  {
    service.sin_family      = AF_INET;
    service.sin_addr.s_addr = Address;
    service.sin_port        = htons(Port);

    if (bind(Socket, (struct sockaddr *)&service, sizeof(service)) == 0)
    {
      if (listen(Socket, 1) == 0) // accept only one simultaneous connection
      {
        return 1;
      }
    }
  }

  return 0;
}

// Check if an incoming connection is made on a listening socket, does not block
// returns new Socket or SOCKET_ERROR (= no incoming connection)
//
OS_SOCKETTYPE Network_CheckAccept(OS_SOCKETTYPE Socket)
{
  fd_set list;
  int nfds;
  int result;
  struct timeval timeout = {0, 0};
  struct linger lingeropt = {1, 10};
  OS_SOCKETTYPE NewSocket = SOCKET_ERROR;

  FD_ZERO(&list);
  FD_SET(Socket, &list);

  #ifdef WINDOWS
    nfds = 0;
  #else
    nfds = Socket+1;
  #endif

  result = select(nfds, &list, NULL, NULL, &timeout);

  if (result > 0)
  {
    // accept should succeed now
    if ((NewSocket = accept(Socket, 0, 0)) != SOCKET_ERROR)
    {
      // set the linger option so remaining data is sent on close
      setsockopt(Socket, SOL_SOCKET, SO_LINGER, (void *)&lingeropt, sizeof(lingeropt));
    }
  }

  return NewSocket;
}


// Check if commands are ready for reading
//
// Returns:
//   0 = no data
//   1 = data available
//   2 = disconnect
integer Network_CheckData(OS_SOCKETTYPE Socket)
{
  fd_set list;
  int nfds;
  int result;
  struct timeval timeout = {0, 0};

  FD_ZERO(&list);
  FD_SET(Socket, &list);

  #ifdef WINDOWS
    nfds = 0;
  #else
    nfds = Socket+1;
  #endif

  result = select(nfds, &list, NULL, NULL, &timeout);

  if (result < 0)
    return 2;
  else if (result == 0)
    return 0;
  else
    return 1;
}

// Ensure the data is read fully
// Returns true if ok, false if network disconnect
//
integer Network_ReceiveData(OS_SOCKETTYPE Socket, char *Buffer, int Size)
{
  int Received;
  int Result;

  // Receive the command, be ready for reading only a part (even in blocking mode)
  //
  Received = 0;
  while (Received < Size)
  {
    Result = recv(Socket, Buffer + Received, Size - Received, 0);

    if (OS_DisconnectRecv(Result))
      return 0;
    else
      Received += Result;
  }

  return 1;
}




// Blocking send of data
// Returns true if ok, false if network disconnect
//
integer Network_SendData(OS_SOCKETTYPE Socket, char *Buffer, int Size)
{
  int Sent;
  int Result;

  // Send the data, be ready for not sending all, even in blocking mode
  //
  Sent = 0;
  while (Sent < Size)
  {
    Result = send(Socket, Buffer + Sent, Size - Sent, 0);

    if (OS_DisconnectSend(Result))
      return 0;
    else
      Sent += Result;
  }

  return 1;
}

// Blocking send of string data (ascii)
// Returns true if ok, false if network disconnect
//
integer Network_SendString(OS_SOCKETTYPE Socket, char *String)
{
  return Network_SendData(Socket, String, strlen(String));
}

