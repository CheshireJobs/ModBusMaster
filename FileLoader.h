#ifndef FILELOADER_H
#define FILELOADER_H
#include <QFile>

class FileLoader
{
public:
    FileLoader();

    void readFile(QString nameFile);
    void writeFile(QString nameFile);

private:
    QString m_nameFile;

};

#endif // FILELOADER_H
