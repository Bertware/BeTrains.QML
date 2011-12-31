import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import "../components"
import "../js/utils.js" as Utils

Page {
    id: page
    anchors.fill: parent

    property date datetime: new Date()


    //
    // Toolbar
    //

    tools: ToolBarLayout {
        // Back buton
        ToolButton {
            flat: true
            iconSource: "toolbar-back"
            onClicked: pageStack.depth <= 1 ? Qt.quit() : pageStack.pop();
        }

        // Make request
        ToolButton {
            iconSource: "toolbar-search"
            enabled: originField.text !== "" && destinationField.text !== ""
            onClicked: {
                connectionsPage = Utils.getDynamicObject(connectionsPage, connectionsComponent, page)
                pageStack.push(connectionsPage, {
                               origin: originField.text,
                               destination: destinationField.text,
                               datetime: buttonTypeNow.checked ? new Date() : datetime,
                               arrival: buttonTypeArrive.checked
                });
            }
        }

        // Menu
        ToolButton {
            iconSource: "toolbar-menu"
            onClicked: {
                window.menu = Utils.getDynamicObject(window.menu, menuComponent, window)
                window.menu.open()
            }
        }
    }


    //
    // Contents
    //

    Column {
        id: contents
        spacing: platformStyle.paddingMedium

        width: parent.width
        anchors {
            fill: parent
            margins: platformStyle.paddingMedium
        }

        Row {
            width: parent.width
            spacing: platformStyle.paddingMedium

            Column {
                id: stationColumn
                width: parent.width - swapButton.width - platformStyle.paddingMedium
                spacing: platformStyle.paddingSmall

                StationField {
                    id: originField
                    placeholderText: "Origin..."
                    width: parent.width
                    KeyNavigation.tab: destinationField
                }

                StationField {
                    id: destinationField
                    placeholderText: "Destination..."
                    width: parent.width
                }
            }

            Button {
                id: swapButton
                height: stationColumn.height
                iconSource: "../icons/swap.png"

                onClicked: {
                    var temp = destinationField.text
                    destinationField.text = originField.text
                    originField.text = temp
                    swapButton.focus = true
                }
            }
        }

        ButtonRow {
            id: groupType
            width: parent.width
            exclusive: true
            checkedButton: buttonTypeNow

            ToolButton {
                id: buttonTypeDepart
                text: "Depart"
            }
            ToolButton {
                id: buttonTypeNow
                text: "Now"
            }
            ToolButton {
                id: buttonTypeArrive
                text: "Arrive";
            }
        }

        Row {
            width: parent.width
            spacing: platformStyle.paddingMedium

            Button {
                id: dateField
                text: datetime.toLocaleDateString()
                enabled: !buttonTypeNow.checked
                width: (parent.width - platformStyle.paddingMedium) / 2

                DatePickerDialog {
                    id: dateDialog
                    titleText: "Select the date"
                    rejectButtonText: "Cancel"
                    acceptButtonText: "Ok"

                    Component.onCompleted: {
                        year = datetime.getFullYear()
                        month = datetime.getMonth()
                        day = datetime.getDate()
                    }

                    onAccepted: datetime = new Date(year, month, day, datetime.getHours(), datetime.getMinutes(), datetime.getSeconds(), datetime.getMilliseconds())
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: dateDialog.open()
                }
            }

            Button {
                id: timeField
                text: Utils.readableTime(datetime)
                enabled: !buttonTypeNow.checked
                width: (parent.width - platformStyle.paddingMedium) / 2

                TimePickerDialog {
                    id: timeDialog
                    titleText: "Select the time"
                    rejectButtonText: "Cancel"
                    acceptButtonText: "Ok"

                    Component.onCompleted: {
                        hour = datetime.getHours()
                        minute = datetime.getMinutes()
                        second = datetime.getSeconds()
                    }

                    onAccepted: datetime = new Date(datetime.getFullYear(), datetime.getMonth(), datetime.getDate(), hour, minute, second, 0)
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: timeDialog.open()
                }
            }
        }
    }


    //
    // Dynamic components
    //

    property ConnectionsPage connectionsPage
    Component {
        id: connectionsComponent

        ConnectionsPage {}
    }
}
