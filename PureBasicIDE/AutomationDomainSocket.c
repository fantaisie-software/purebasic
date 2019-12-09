/*--------------------------------------------------------------------------------------------
 * Copyright (c) Fantaisie Software. All rights reserved.
 * Dual licensed under the GPL and Fantaisie Software licenses.
 * See LICENSE and LICENSE-FANTAISIE in the project root for license information.
 *--------------------------------------------------------------------------------------------
 *
 * Functions for communication via Unix domain sockets
 *
 * The socket API uses complex C macros, so it is just easier
 * to do this part in C and import it into PB.
 *
 * This is used on Linux and OSX for the automation support
 */

#include <PureLibrary.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <errno.h>

// used for allocating memory for received calls
//
extern M_PBFUNCTION(void *) PB_AllocateMemory(integer Size);
extern M_PBFUNCTION(void) PB_FreeMemory(void *Memory);

#define SOCKET_ERROR (-1)

// create a (non-blocking) unix domain socket on the given filename
// returns the socket if successful, -1 else
//
integer DomainSocket_Create(char *Path)
{
  int Socket;
  struct sockaddr_un local;

  if ((Socket = socket(AF_UNIX, SOCK_STREAM, 0)) >= 0)
  {
    local.sun_family = AF_UNIX;
    strcpy(local.sun_path, Path);

    if (bind(Socket, (struct sockaddr *)&local, sizeof(struct sockaddr_un)) == 0)
    {
      listen(Socket, 10);
    }
    else
    {
      // bind failed, maybe the file exists already
      close(Socket);
      Socket = SOCKET_ERROR;
    }
  }

  return Socket;
}

// accept a new connection on the given socket (if any)
// returns new socket or -1 on if no connection is available
//
integer DomainSocket_Accept(int Socket)
{
  fd_set list;
  int nfds;
  int result;
  struct timeval timeout = {0, 0};
  struct linger lingeropt = {1, 10};
  int NewSocket = SOCKET_ERROR;

  FD_ZERO(&list);
  FD_SET(Socket, &list);
  nfds = Socket+1;

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

// connect to a domain socket as a client
// returns new socket or -1
//
integer DomainSocket_Connect(char *Path)
{
  int Socket;
  struct sockaddr_un local;

  if ((Socket = socket(AF_UNIX, SOCK_STREAM, 0)) >= 0)
  {
    local.sun_family = AF_UNIX;
    strcpy(local.sun_path, Path);

    if (connect(Socket, (struct sockaddr *)&local, sizeof(struct sockaddr_un)) != 0)
    {
      // connection failed
      close(Socket);
      Socket = SOCKET_ERROR;
    }
  }

  return Socket;
}

// close the socket, this is for both server and client
//
void DomainSocket_Close(int Socket)
{
  close(Socket);
}

// send a command. This expects the following form (provided by the RemoteProcedureCall.pb encoding)
// Long: total size (including this field)
// <data>
// returns true on success
//
integer DomainSocket_Send(int Socket, char *Buffer)
{
  int Size = *(int *)Buffer;
  int Sent;
  int Result;

  Sent = 0;
  while (Sent < Size)
  {
    Result = send(Socket, Buffer + Sent, Size - Sent, 0);

    if ((Result == -1) && (errno = ECONNRESET))
      return 0;
    else
      Sent += Result;
  }

  return 1;
}

// receive a command. This expects the data format as above.
// returns a buffer allocated with AllocateMemory() on success
// returns 0 if there is no data
// returns -1 if the connection was closed
//
char *DomainSocket_Receive(int Socket)
{
  int Received;
  int Result;
  int Size;
  char *Buffer;

  // Receive the size of the buffer (sent first)
  //
  Result = recv(Socket, (void *)&Size, 4, MSG_DONTWAIT | MSG_PEEK);

  if (Result == 0)
    return (char *)(-1); // client shutdown
  else if (((Result == -1) && (errno == EAGAIN)) || ((Result > 0) && (Result < 4)))
    return NULL; // no data available (or not enough)

  Buffer = PB_AllocateMemory(Size);
  if (Buffer == 0)
    return NULL;

  // receive all data
  // this blocks until it is available, but can still return less than the total size
  // if a signal is caught!
  Received = 0;
  while (Received < Size)
  {
    Result = recv(Socket, Buffer + Received, Size - Received, MSG_WAITALL);

    if (Result == 0)
    {
      PB_FreeMemory(Buffer);
      return (void *)(-1); // indicate error
    }
    else
      Received += Result;
  }

  return Buffer;
}

