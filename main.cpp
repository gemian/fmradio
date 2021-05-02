#include <QGuiApplication>
#include <QCoreApplication>
#include <QUrl>
#include <QString>
#include <QQuickView>
#include <QQmlEngine>

class FMRadioApplication : public QGuiApplication {

public:
	FMRadioApplication(int &argc, char **argv);

	virtual ~FMRadioApplication() override;

private:
	QQuickView *m_view;
};

FMRadioApplication::FMRadioApplication(int &argc, char **argv)
: QGuiApplication(argc, argv), m_view(nullptr) {
	auto *view = new QQuickView();
	QObject::connect(view->engine(), SIGNAL(quit()), SLOT(quit()));
	view->setSource(QUrl("qrc:/Main.qml"));
	view->setResizeMode(QQuickView::SizeRootObjectToView);
	view->show();
}

FMRadioApplication::~FMRadioApplication() {
	delete m_view;
}

int main(int argc, char** argv)
{
	FMRadioApplication application(argc, argv);
	QGuiApplication::setApplicationName("FM Radio");

	qDebug() << "Starting app from main.cpp";

	int ret = QGuiApplication::exec();
	return ret;
}
