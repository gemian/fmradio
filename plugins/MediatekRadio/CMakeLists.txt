set(CMAKE_CXX_STANDARD 11)

find_package(ECM REQUIRED NO_MODULE)
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui Widgets DBus)
find_package(PkgConfig REQUIRED)

include_directories(
        ${QT5_INCLUDE_DIRS}
)

add_library(mediatek-radio-plugin SHARED plugin.cpp MediatekRadio.cpp)

target_include_directories(mediatek-radio-plugin PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(mediatek-radio-plugin
        Qt5::Gui
        Qt5::Qml
        Qt5::Quick
        Qt5::Widgets
        Qt5::DBus
        ${CMAKE_DL_LIBS}
        )


install(TARGETS mediatek-radio-plugin LIBRARY DESTINATION ${KDE_INSTALL_QMLDIR}/org/gemian/MediatekRadio)
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/gemian/MediatekRadio)
