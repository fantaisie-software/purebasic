/* --------------------------------------------------------------------------------------------
 *  Copyright (c) Fantaisie Software. All rights reserved.
 *  Dual licensed under the GPL and Fantaisie Software licenses.
 *  See LICENSE and LICENSE-FANTAISIE in the project root for license information.
 * --------------------------------------------------------------------------------------------
 */
 
#include <QtWidgets/QtWidgets>

#ifdef PB_64
  typedef long long integer;
#else
  typedef int integer;
#endif

extern QApplication *PB_QT_Application;

typedef integer (*EventHandlerProc)(QEvent *Event);

class EventFilter : public QObject
{
    Q_OBJECT
    
public:
  EventFilter(QWidget *Target, EventHandlerProc Handler);

protected:
    bool eventFilter(QObject *obj, QEvent *event) override;
    
private:
    EventHandlerProc Handler;
};

