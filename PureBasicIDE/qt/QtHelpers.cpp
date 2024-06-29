/* --------------------------------------------------------------------------------------------
 *  Copyright (c) Fantaisie Software. All rights reserved.
 *  Dual licensed under the GPL and Fantaisie Software licenses.
 *  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
 * --------------------------------------------------------------------------------------------
 */
 
/*
 * IDE helper functions for stuff that cannot be done directly via QtScript() because the
 * needed functionality is not available via scripting.
 *
 * Note: Stuff that can be done with QtScript() should be done this way and not have
 *       a helper function here.
 *
 */
 
#include <QtHelpers.h>

// -------------------  Misc functions -----------------

extern "C" void Qt_ScrollEditorToBottom(QTextEdit *Widget)
{
  QScrollBar *Scroll;
  
  if (Scroll = Widget->verticalScrollBar())
    Scroll->setValue(Scroll->maximum());
}


extern "C" void QT_CenterEditor(QTextEdit *Widget)
{
  QTextCursor Cursor = Widget->textCursor();
  
  Widget->selectAll(); // otherwise the change only applies to the next inserted paragraph
  Widget->setAlignment(Qt::AlignCenter);
  
  Cursor.movePosition(QTextCursor::Start);
  Widget->setTextCursor(Cursor);
}


extern "C" void QT_SelectComboBoxText(QComboBox *Widget)
{
  Widget->lineEdit()->selectAll(); 
}


extern "C" integer QT_GetListViewScroll(QListWidget *Widget)
{
  QScrollBar *Scroll;
  
  if (Scroll = Widget->verticalScrollBar())
    return Scroll->value();
  
  return 0;
}


extern "C" void QT_SetListViewScroll(QListWidget *Widget, integer Value)
{
  QScrollBar *Scroll;
  
  if (Scroll = Widget->verticalScrollBar())
    Scroll->setValue(Value);
}


extern "C" integer QT_Frame3DTopOffset(QGroupBox *Widget)
{
  return Widget->fontMetrics().height() + 5; // add space for the box part
}


extern "C" void QT_SetDefaultWindowIcon(QImage *Image)
{
  PB_QT_Application->setWindowIcon(QIcon(QPixmap::fromImage(*Image)));
}


extern "C" integer QT_WindowBackgroundColor(QMainWindow *Window)
{
  QColor c = Window->palette().color(QPalette::Active, QPalette::Window).convertTo(QColor::Rgb);
  return c.red() | c.green() << 8 | c.blue() << 16;
}

extern "C" QWidget *QT_GetViewPort(QAbstractScrollArea *Widget)
{
  return Widget->viewport();
}

// -------------------  Event handling for AutoComplete -----------------


EventFilter::EventFilter(QWidget *Target, EventHandlerProc Handler):
  QObject(Target), // make this a child object of Target so it gets freed with it
  Handler(Handler)
{
}

bool EventFilter::eventFilter(QObject *obj, QEvent *event)
{
  if (Handler(event))
    return true; // event handled
  else
    return QObject::eventFilter(obj, event); // standard event processing
}

extern "C" void QT_SetEventFilter(QWidget *Widget, EventHandlerProc Handler)
{
  Widget->installEventFilter(new EventFilter(Widget, Handler));
} 

extern "C" void QT_SendEvent(QWidget *Widget, QEvent *Event)
{
  PB_QT_Application->sendEvent(Widget, Event);
} 

extern "C" integer QT_EventType(QEvent *Event)
{
  return Event->type();
}

extern "C" integer QT_EventKey(QKeyEvent *Event)
{
  return Event->key();
}

extern "C" integer QT_EventButton(QMouseEvent *Event)
{
  return Event->button();
}
