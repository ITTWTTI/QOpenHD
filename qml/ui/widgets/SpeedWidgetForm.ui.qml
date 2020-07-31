import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import QtQuick.Shapes 1.0

import Qt.labs.settings 1.0

import OpenHD 1.0

BaseWidget {
    id: speedWidget
    width: 64
    height: 24

    visible: settings.show_speed

    defaultXOffset: 20
    defaultVCenter: true

    widgetIdentifier: "speed_widget"

    defaultHCenter: false

    hasWidgetDetail: true
    widgetDetailHeight: 224
    widgetDetailWidth: 264

    widgetDetailComponent: Column {
        id: speedSettingsColumn
        spacing: 0

        Item {
            width: parent.width
            height: 32
            Text {
                id: opacityTitle
                text: qsTr("Transparency")
                color: "white"
                height: parent.height
                font.bold: true
                font.pixelSize: detailPanelFontPixels
                anchors.left: parent.left
                verticalAlignment: Text.AlignVCenter
            }
            Slider {
                id: speed_opacity_Slider
                orientation: Qt.Horizontal
                from: .1
                value: settings.speed_opacity
                to: 1
                stepSize: .1
                height: parent.height
                anchors.rightMargin: 0
                anchors.right: parent.right
                width: parent.width - 96

                onValueChanged: {
                    settings.speed_opacity = speed_opacity_Slider.value
                }
            }
        }
        Item {
            width: parent.width
            height: 32
            Text {
                id: sizeTitle
                text: qsTr("Size")
                color: "white"
                height: parent.height
                font.bold: true
                font.pixelSize: detailPanelFontPixels
                anchors.left: parent.left
                verticalAlignment: Text.AlignVCenter
            }
            Slider {
                id: speed_size_Slider
                orientation: Qt.Horizontal
                from: .7
                value: settings.speed_size
                to: 3
                stepSize: .1
                height: parent.height
                anchors.rightMargin: 0
                anchors.right: parent.right
                width: parent.width - 96

                onValueChanged: {
                    settings.speed_size = speed_size_Slider.value
                }
            }
        }
        Item {
            width: parent.width
            height: 32
            Text {
                text: qsTr("Airspeed / GPS")
                horizontalAlignment: Text.AlignRight
                color: "white"
                height: parent.height
                font.bold: true
                font.pixelSize: detailPanelFontPixels
                anchors.left: parent.left
                verticalAlignment: Text.AlignVCenter
            }
            Switch {
                width: 32
                height: parent.height
                anchors.rightMargin: 6
                anchors.right: parent.right
                checked: settings.speed_airspeed_gps
                onCheckedChanged: settings.speed_airspeed_gps = checked
            }
        }
        Item {
            width: parent.width
            height: 32
            Text {
                text: qsTr("Show ladder")
                color: "white"
                height: parent.height
                font.bold: true
                font.pixelSize: detailPanelFontPixels
                anchors.left: parent.left
                verticalAlignment: Text.AlignVCenter
            }
            Switch {
                width: 32
                height: parent.height
                anchors.rightMargin: 6
                anchors.right: parent.right
                checked: settings.show_speed_ladder
                onCheckedChanged: settings.show_speed_ladder = checked
            }
        }
        Item {
            width: parent.width
            height: 32
            Text {
                text: qsTr("Range")
                color: "white"
                height: parent.height
                font.bold: true
                font.pixelSize: detailPanelFontPixels
                anchors.left: parent.left
                verticalAlignment: Text.AlignVCenter
            }
            Slider {
                id: speed_range_Slider
                orientation: Qt.Horizontal
                from: 40
                value: settings.speed_range
                to: 150
                stepSize: 10
                height: parent.height
                anchors.rightMargin: 0
                anchors.right: parent.right
                width: parent.width - 96

                onValueChanged: { // @disable-check M223
                    settings.speed_range = speed_range_Slider.value;
                    if (!settings.show_speed_ladder) {
                        return;
                    }
                    canvasSpeedLadder.requestPaint();
                }
            }
        }
        Item {
            width: parent.width
            height: 32
            Text {
                text: qsTr("Minimum")
                color: "white"
                height: parent.height
                font.bold: true
                font.pixelSize: detailPanelFontPixels
                anchors.left: parent.left
                verticalAlignment: Text.AlignVCenter
            }
            Slider {
                id: speed_minimum_Slider
                orientation: Qt.Horizontal
                from: 0
                value: settings.speed_minimum
                to: 50
                stepSize: 10
                height: parent.height
                anchors.rightMargin: 0
                anchors.right: parent.right
                width: parent.width - 96

                onValueChanged: { // @disable-check M223
                    settings.speed_minimum = speed_minimum_Slider.value
                    if (!settings.show_speed_ladder || !settings.show_speed) {
                        return;
                    }
                    canvasSpeedLadder.requestPaint();
                }
            }
        }
    }

    Item {
        id: widgetInner
        anchors.fill: parent
        opacity: settings.speed_opacity

        //-----------------------ladder start---------------
        Item {
            id: speedLadder

            anchors.right: parent.right
            anchors.rightMargin: 20 //tweak ladder left or right

            visible: settings.show_speed_ladder

            transform: Scale { origin.x: -33; origin.y: 12; xScale: settings.speed_size ; yScale: settings.speed_size}

            Connections{
                target:OpenHD
                function onSpeedChanged() {
                    if (!settings.show_speed_ladder || !settings.show_speed) {
                        return;
                    }

                    // if user selects msl it is part of same mavlink msg
                    canvasSpeedLadder.requestPaint()
                }
            }

            Canvas {
                id: canvasSpeedLadder
                anchors.centerIn: parent
                width: 50
                height: 300
                clip: false
                renderTarget: Canvas.FramebufferObject
                renderStrategy: Canvas.Cooperative

                onPaint: { // @disable-check M223
                    if (!settings.show_speed_ladder || !settings.show_speed) {
                        return;
                    }
                    var ctx = getContext("2d"); // @disable-check M222
                    ctx.reset(); // @disable-check M222

                    if (settings.show_speed_ladder === false){
                        return; // to stop it from painting per user selection
                    }

                    ctx.fillStyle = settings.color_shape;
                    //cant get a good approximation of glow via canvas
                    //ctx.strokeStyle = settings.color_glow;
                    //ctx.lineWidth = .5;
                    ctx.font = "bold 11px sans-serif";

                    var speed_airspeed_gps = settings.speed_airspeed_gps;
                    var _airspeed = OpenHD.airspeed;
                    var _speed = OpenHD.speed;

                    var speed = settings.enable_imperial ? (speed_airspeed_gps ? (_airspeed*0.621371) : (_speed*0.621371)) :
                                                           (speed_airspeed_gps ? _airspeed : _speed);
                    //weird rounding issue where decimals make ladder dissappear
                    speed=Math.round(speed);

                    var x = 32; // ticks right/left position
                    var y_position= height/2+11; // ladder center up/down..tweak
                    var x_label = 10; // ladder labels right/left position

                    var range = settings.speed_range; // speed range range of display, i.e. lowest and highest number on the ladder
                    var ratio_speed = height / range;

                    var k;
                    var y;

                    var speed_minimum = settings.speed_minimum;

                    for (k = (speed - range / 2); k <= speed + range / 2; k++) {    // @disable-check M223
                        y =  y_position + ((k - speed) * ratio_speed)*-1;
                        if (k % 10 == 0) {                                      // @disable-check M223
                            if (k >= 0) {                                       // @disable-check M223
                                /// big ticks
                                ctx.rect(x, y, 12, 3);
                                ctx.fill();                                     // @disable-check M222
                                //ctx.stroke();
                                if (k>speed+5 || k<speed-5){                        // @disable-check M223
                                    // text
                                    ctx.fillText(k, x_label, y+6);              // @disable-check M222
                                }
                            }
                            if (k < speed_minimum) {                                        // @disable-check M223
                                //start position speed (squares) below "0"
                                ctx.rect(x, y-12, 15, 15);
                                ctx.fill();                                     // @disable-check M222
                                //ctx.stroke();
                            }
                        }
                        else if ((k % 5 == 0) && (k > speed_minimum)) {                      // @disable-check M223
                            //little ticks
                            ctx.rect(x+5, y, 7, 2);
                            ctx.fill(); // @disable-check M222
                            //ctx.stroke();
                        }
                    }
                }
            }
        }
        //-----------------------ladder end---------------



        Text {
            anchors.fill: parent
            id: speed_text
            color: settings.color_text           
            font.pixelSize: 14
            transform: Scale { origin.x: 12; origin.y: 12; xScale: settings.speed_size ; yScale: settings.speed_size}
            text: Number(
                      settings.enable_imperial ?
                      (settings.speed_airspeed_gps ? OpenHD.airspeed*0.621371 : OpenHD.speed*0.621371) :
                      (settings.speed_airspeed_gps ? OpenHD.airspeed : OpenHD.speed)   ).toLocaleString(
                      Qt.locale(), 'f', 0)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            style: Text.Outline
            styleColor: settings.color_glow
        }

        Shape {
            id: outline
            anchors.fill: parent
            rotation: 180
            transform: Scale { origin.x: 12; origin.y: 12; xScale: settings.speed_size ; yScale: settings.speed_size}
            ShapePath {
                strokeColor: settings.color_shape
                strokeWidth: 1
                strokeStyle: ShapePath.SolidLine
                fillColor: "transparent"
                startX: 0
                startY: 12
                PathLine {
                    x: 0
                    y: 12
                }
                PathLine {
                    x: 12
                    y: 0
                }
                PathLine {
                    x: 58
                    y: 0
                }
                PathLine {
                    x: 58
                    y: 24
                }
                PathLine {
                    x: 12
                    y: 24
                }
                PathLine {
                    x: 0
                    y: 12
                }
            }
        }
    }
}



