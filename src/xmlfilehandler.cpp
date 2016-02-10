#include "xmlfilehandler.h"

XmlFileHandler::XmlFileHandler(QObject *parent) : QObject(parent){
    fileLocation = QDir(QStandardPaths::writableLocation(QStandardPaths::DataLocation));

    manager = new QNetworkAccessManager(this);
    connect(manager, SIGNAL(finished(QNetworkReply*)), this, SLOT(replyFinished(QNetworkReply*)));
    headManager = new QNetworkAccessManager(this);
    connect(headManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(getHeaders(QNetworkReply*)));
    connect(this, SIGNAL(fileStatChanged(int)), this, SLOT(catchFileStatChange(int)));

    stat = 0;
    timeStamp = QDateTime::currentDateTime();
    for(int i=0; i<25;i++){
        nextEvents << "";
    }
}

void XmlFileHandler::load(const QString &filePath, const QString &fileName){
    fileUrl = fileLocation.filePath(fileName);
    url = filePath + fileName;
    xmlInfo = QFileInfo(fileUrl);
    if (xmlInfo.exists()) {
        // Check if local file is up to date
//        qDebug() << "Found file check if up to date";
        headManager->head(QNetworkRequest(url));
    } else {
//        qDebug() << "Need to download something here";
        if(QDir().mkpath(fileLocation.path())){
            manager->get(QNetworkRequest(url));
        }else{
            setFileStat(-1); // Error no file to display
        }
    }
}

void XmlFileHandler::getHeaders(QNetworkReply *reply){
    if (reply->operation() == QNetworkAccessManager::HeadOperation){
//        qDebug() << reply->header(QNetworkRequest::LastModifiedHeader).toDateTime();
//        qDebug() << xmlInfo.lastModified().toLocalTime();
        if(xmlInfo.lastModified().toLocalTime()>reply->header(QNetworkRequest::LastModifiedHeader).toDateTime()){
            setFileStat(2); // File is still up to date
        }else{
            qDebug() << "Update required";
            manager->get(QNetworkRequest(url));
        }
    }else{
        setFileStat(1);
    }
    reply->deleteLater();
}

void XmlFileHandler::replyFinished(QNetworkReply *reply){
    int newFileStat;

    if(reply->error())        {
        qDebug() << "ERROR!";
        qDebug() << reply->errorString();
        newFileStat = 1; // Fall back to existing file
    }else{
        QFile *file = new QFile(fileUrl);
        if(file->open(QIODevice::ReadWrite | QIODevice::Truncate)){
            QTextStream out(file);
            out << reply->readAll();
            qDebug() << out.status();
            file->flush();
            newFileStat = 3; // File was updated
        }else{
            qDebug() << "Error opening file" << file->errorString();
            newFileStat = 1;
        }
        file->close();
    }
    reply->deleteLater();
    setFileStat(newFileStat);
}

void XmlFileHandler::catchFileStatChange(int stat){
    qDebug() << stat;
}

QString XmlFileHandler::filePath(){
    return fileUrl;
}
int XmlFileHandler::fileStat(){
    return stat;
}
void XmlFileHandler::setFileStat(const int curStat){
    if(stat != curStat){
        stat = curStat;
        if(curStat > 0){
            nextEvent();
        }
        fileStatChanged(stat);
    }
}

void XmlFileHandler::clear(){
    QFile *file = new QFile(fileUrl);
    file->remove();
    xmlInfo = QFileInfo(fileUrl);
}

void XmlFileHandler::setNextEventsArray(QList<QString>){
    for(int i=0; i<25;i++){
        nextEvents << "event";
    }
}

void XmlFileHandler::nextEvent(){
    QFile *xmlFile = new QFile(fileUrl);
    if (!xmlFile->open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << xmlFile->errorString();
        return;
    }
    QXmlStreamReader *xml = new QXmlStreamReader(xmlFile);

    while(!xml->atEnd() && !xml->hasError()){
        // Read next element.
        QXmlStreamReader::TokenType token = xml->readNext();
        // If token is just StartDocument, we'll go to next.
        if(token == QXmlStreamReader::StartDocument)
            continue;

        if(xml->name().toString() == "termin" && token != QXmlStreamReader::EndElement) {
            int index = xml->attributes().value("type").toInt()*4;
            xml->readNext();

            if(token == QXmlStreamReader::StartElement && nextEvents.at(index).isEmpty()) {
                QDateTime eventTime = QDateTime::fromTime_t(xml->readElementText().toInt());
               if(xml->name() == "datum" && eventTime > timeStamp) {
                   // Speichere die Timestamps von nächsten internen und externen BA um später entscheiden zu können welcher angezeigt werden soll
                   if(index == 0)
                       nextOpenBa = eventTime.toTime_t();
                   else if(index == 4)
                       nextIntBa = eventTime.toTime_t();

                   // Schreibe Array mit Daten
                    nextEvents.replace(index, eventTime.toString("dd.MM.yy - hh:mm"));
                    xml->readNext();
                    nextEvents.replace(index+1, xml->readElementText());
                    xml->readNext();
                    nextEvents.replace(index+2, xml->readElementText());
                    xml->readNext();
                    nextEvents.replace(index+3, xml->readElementText());
                    continue;
                }
            }
        }
    }
    // Error handling.
    if(xml->hasError())
        qDebug() << xml->errorString();

    // Check which BA is most recent
    if(nextOpenBa < nextIntBa || nextEvents.at(4).isEmpty()){
        nextEvents.replace(24, "0");
    }else{
        nextEvents.replace(24,"4");
    }
    //resets its internal state to the initial state.
    xml->clear();
    xmlFile->close();
    nextEventsArrayChanged();
}
