import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12

import QtQuick.Shapes 1.0
import QtQuick.Controls.Material 2.0

import Qt.labs.settings 1.0

import OpenHD 1.0

import "../elements"

SideBarBasePanel{
    override_title: "OpenHD RC"

    function takeover_control(){
        joy_rc_enable.takeover_control();
    }

    property int m_control_yaw : settings.control_widget_use_fc_channels ? _rcchannelsmodelfc.control_yaw : _rcchannelsmodelground.control_yaw
    property int m_control_roll: settings.control_widget_use_fc_channels ? _rcchannelsmodelfc.control_roll : _rcchannelsmodelground.control_roll
    property int m_control_pitch: settings.control_widget_use_fc_channels ? _rcchannelsmodelfc.control_pitch : _rcchannelsmodelground.control_pitch
    property int m_control_throttle: settings.control_widget_use_fc_channels ? _rcchannelsmodelfc.control_throttle : _rcchannelsmodelground.control_throttle

    Column {
        id: rcpanel
        anchors.top: parent.top
        anchors.topMargin: secondaryUiHeight / 8
        spacing: 5

        MavlinkChoiceElement2 {
            id: joy_rc_enable
            m_title: "Joystick"
            m_param_id: "ENABLE_JOY_RC"
            m_settings_model: _ohdSystemGroundSettings
            onGoto_previous: {
                sidebar.regain_control_on_sidebar_stack()
            }
            onGoto_next: {
                sidebar.regain_control_on_sidebar_stack()
            }
        }

        Rectangle {
            color: "transparent"
            height: 260
            width: 320

            Rectangle {
                id: innerRectangle
                color: "transparent"
                width: parent.width - 25
                height: parent.height-75
                anchors.centerIn: parent

                Column {
                    anchors.fill: parent
                    spacing: 5

                    RCChannelView {
                        override_channel_index: 0
                        height: 50
                    }
                    RCChannelView {
                        override_channel_index: 1
                        height: 50
                    }
                    RCChannelView {
                        override_channel_index: 2
                        height: 50
                    }
                    RCChannelView {
                        override_channel_index: 3
                        height: 50
                    }
                }
            }
        }
}
}
