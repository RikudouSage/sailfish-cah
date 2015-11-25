#ifndef PING_H
#define PING_H

#include <QObject>
#include <QDebug>
#include "exec.h"

class Ping : public QObject {
    Q_OBJECT
public:
    Q_INVOKABLE bool networkAccessible() const {
        QString networkstate = exec("ping -c 1 www.google.cz").c_str();
        bool networkAccessible = networkstate.contains("1 packets transmitted");
        return networkAccessible;
    }
};

#endif // PING_H
