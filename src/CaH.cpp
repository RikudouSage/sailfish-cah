#include <QtQuick>
#include <QDebug>
#include <sailfishapp.h>
#include "exec.h"
#include "ping.h"


int main(int argc, char *argv[])
{
    Ping ping;
    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();
    QString qml = QString("qml/CaH.qml");
    view->rootContext()->setContextProperty("ping",&ping);
    view->setSource(SailfishApp::pathTo(qml));
    view->show();
    return app->exec();
//    return SailfishApp::main(argc, argv);
}

std::string exec(const char* cmd) {
    FILE* pipe = popen(cmd, "r");
    if (!pipe) return "ERROR";
    char buffer[128];
    std::string result = "";
    while(!feof(pipe)) {
        if(fgets(buffer, 128, pipe) != NULL)
            result += buffer;
    }
    pclose(pipe);
    return result;
}
