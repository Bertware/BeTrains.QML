import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
import "../components"
import "../js/utils.js" as Utils
import "../js/storage.js" as Storage

Page {
    id: page
    anchors.fill: parent

    property date __datetime: new Date()
    property bool __datetimeSpecified: false
    property bool __departure: true


    //
    // Contents
    //

    Column {
        id: configuration
        spacing: platformStyle.paddingMedium

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: platformStyle.paddingMedium
        }

        Row {
            width: parent.width
            spacing: platformStyle.paddingMedium

            Column {
                id: stationColumn
                width: parent.width - swapButton.width - parent.spacing
                spacing: platformStyle.paddingSmall

                StackableSearchBox {
                    id: originField
                    placeHolderText: "Origin..."
                    width: parent.width
                    KeyNavigation.tab: destinationField
                }

                StackableSearchBox {
                    id: destinationField
                    placeHolderText: "Destination..."
                    width: parent.width
                }
            }

            Button {
                id: swapButton
                height: stationColumn.height
                iconSource: "../icons/swap.png"

                onClicked: {
                    var temp = destinationField.searchText
                    destinationField.searchText = originField.searchText
                    originField.searchText = temp
                    swapButton.focus = true
                }
            }
        }

        SelectionListItem {
            title: (__departure ? "Departure" : "Arrival")
            subTitle:  (__datetimeSpecified ? (__datetime.toLocaleString()) : "Right now")

            function __onDialogAccepted() {
                __departure = datetimeDialog.departure
                __datetime = datetimeDialog.datetime
                __datetimeSpecified = datetimeDialog.specified
            }

            width: parent.width
            onClicked: {
                if (!datetimeDialog) {
                    datetimeDialog = Utils.loadObjectByPath("components/TravelTimeDialog.qml", page)
                    datetimeDialog.accepted.connect(__onDialogAccepted)
                }
                datetimeDialog.departure = __departure
                datetimeDialog.datetime = __datetime
                datetimeDialog.specified = __datetimeSpecified
                datetimeDialog.open()
            }
        }
    }

    ListView {
        id: historyView

        anchors {
            left: parent.left
            right: parent.right
            top: configuration.bottom
            bottom: parent.bottom
            topMargin: platformStyle.paddingLarge
        }

        clip: true
        model: historyModel
        header: Component {
            ListItem {
                id: item
                subItemIndicator: true

                // FIXME: silence some errors
                property int index: 0

                ListItemText {
                    anchors.fill: item.paddingItem
                    text: "New query"
                }

                onClicked: {
                    if (!connectionsPage)
                        connectionsPage = Utils.loadObjectByPath("pages/ConnectionsPage.qml", page)

                    if (originField.searchText === "" || destinationField.searchText === "") {
                        banner.text = "Please fill out both station fields"
                        banner.open()
                    } else {
                        historyModel.addConnection({"origin": originField.searchText,
                                                    "destination": destinationField.searchText,
                                                    "datetimeSpecified": __datetimeSpecified,
                                                    "datetime": __datetime.getTime(),
                                                    "departure": __departure,
                                                    "favorite": false})
                        pageStack.push(connectionsPage, {
                                       origin: originField.searchText,
                                       destination: destinationField.searchText,
                                       datetime: __datetimeSpecified ? __datetime : new Date(),
                                       departure: __departure,
                                       lockDatetime: __datetimeSpecified
                        });
                    }
                }
            }
        }

        delegate: historyDelegate
    }

    InfoBanner {
         id: banner
    }


    //
    // Data
    //

    ListModel {
        id: historyModel

        Component.onCompleted: {
            Storage.getConnections(historyModel)
        }

        function addConnection(connection) {
            append(connection)
            console.log(Storage.addConnection(connection))
        }
    }

    Component {
        id: historyDelegate

        ListItem {
            id: item
            subItemIndicator: true

            Column {
                anchors.fill: item.paddingItem
                id: column1

                ListItemText {
                    id: connectionText
                    mode: item.mode
                    role: "Title"
                    text: origin + " → " + destination
                    font.capitalization: Font.Capitalize
                }
                ListItemText {
                    id: datetimeText
                    mode: item.mode
                    role: "SubTitle"
                    text: {
                        var datetimeString
                        if (departure)
                            datetimeString = "Depart"
                        else
                            datetimeString = "Arrive"
                        if (datetimeSpecified)
                            datetimeString = datetimeString + " at " + (new Date(datetime)).toLocaleString()
                        else
                            datetimeString = datetimeString + " right now"
                        return datetimeString
                    }
                }
            }

            onClicked: {
            }
        }
    }


    //
    // Objects
    //

    property variant connectionsPage
    property variant datetimeDialog
}
