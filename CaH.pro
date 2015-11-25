TARGET = CaH

CONFIG += sailfishapp

SOURCES += src/CaH.cpp

OTHER_FILES += qml/CaH.qml \
    qml/cover/CoverPage.qml \
    rpm/CaH.changes.in \
    rpm/CaH.spec \
    rpm/CaH.yaml \
    translations/*.ts \
    CaH.desktop \
    qml/pages/MainScreen.qml

CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/CaH-cs_CZ.ts

HEADERS += \
    exec.h \
    ping.h

DISTFILES += \
    qml/pages/RegisterDialog.qml \
    qml/pages/GeneralError.qml \
    qml/pages/AlreadyExistsError.qml
