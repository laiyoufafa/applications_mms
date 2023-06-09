/**
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import SettingModel from '../model/SettingsModel';

let mSettingModel = new SettingModel();
import HiLog from '../utils/HiLog';
import common from '../data/commonData';
import LooseObject from '../data/LooseObject'
import preferences from '../utils/PreferencesUtil';

const TAG = 'SettingService';
export default {

    /**
     * 设置初始值
     *
     * @param {Object} callback 回调函数
     */
    setOnSettingValueListener(callback) {
        let result: LooseObject = {
            integrationSwitch: false,
            maliciousWebSwitch: false,
            showContactSwitch: false,
        };
        mSettingModel.setOnSettingValueListener(settingValue => {
            if (settingValue.integrationSwitch === common.bool.TRUE) {
                result.integrationSwitch = true;
            }
            if (settingValue.maliciousWebSwitch === common.bool.TRUE) {
                result.maliciousWebSwitch = true;
            }
            if (settingValue.showContactSwitch === common.bool.TRUE) {
                result.showContactSwitch = true;
            }
        });
        callback(result);
    },

    /**
     * 还原页面的默认值
     *
     * @param {Object} callback 回调函数
     */
    restoreSwitchValue(callback) {
        mSettingModel.restoreSwitchValueToDefault(callback);
    },

    /**
     * 更新相关的值
     * @param code 更新的code
     * @param actionData 更新的值
     * @param callback 回调函数
     * @return
     */
    updateSettingValue(code, actionData, callback) {
        switch (code) {
            case common.route.MESSAGE_CODE_UPDATE_DELIVERY_REPORTS_VALUE:
            // 送达报告
                mSettingModel.updateSwitchValue(common.string.KEY_OF_DELIVERY_REPORT_SWITCH,
                    actionData.intValue, callback);
                break;
            case common.route.MESSAGE_CODE_UPDATE_AUTO_RETRIEVE_MMS_VALUE:
            // 自动下载彩信
                mSettingModel.updateSwitchValue(common.string.KEY_OF_AUTO_RETRIEVE_SWITCH,
                    actionData.intValue, callback);
                break;
            case common.route.MESSAGE_CODE_UPDATE_RECALL_MESSAGES_VALUE:
            // 取消发送
                mSettingModel.updateSwitchValue(common.string.KEY_OF_RECALL_MESSAGE_SWITCH,
                    actionData.booleanValue, callback);
                break;
            case common.route.MESSAGE_CODE_UPDATE_AUTO_DELETE_INFO_MESSAGES_VALUE:
            // 自动删除通知信息
                mSettingModel.updateSwitchValue(common.string.KEY_OF_AUTO_DELETE_INFO_SWITCH,
                    actionData.booleanValue, callback);
                break;
            case common.route.MESSAGE_CODE_UPDATE_ARCHIVE_INFO_MESSAGES_VALUE:
            // 通知信息整合
                mSettingModel.updateSwitchValue(common.string.KEY_OF_INTEGRATION_SWITCH,
                    actionData.booleanValue, callback);
                break;
            case common.route.MESSAGE_CODE_UPDATE_MALICIOUS_WEBSITE_IDENTIFICATION_VALUE:
            // 恶意网址识别
                mSettingModel.updateSwitchValue(common.string.KEY_OF_MALICIOUS_WEB_SWITCH,
                    actionData.booleanValue, callback);
                break;
            case common.route.MESSAGE_CODE_UPDATE_SHOW_CONTACT_PROFILE_PICS_VALUE:
            // 显示联系人头像
                mSettingModel.updateSwitchValue(common.string.KEY_OF_SHOW_CONTACT_SWITCH,
                    actionData.booleanValue, callback);
                break;
            default:
                HiLog.w(TAG, 'updateSettingValue, code is not exit');
        }
    },

    /**
     * 获取高级设置页面开关值
     *
     * @param {Object} callback 回调函数
     */
    getAdvancedPageSwitchValue(callback) {
        mSettingModel.getAdvancedPageSwitchValue(callback);
    },

    /**
     * 更新短信中心号码
     * @param actionData 参数
     * @param callback 回调
     * @return
     */
    updateSmscNumber(actionData) {
        mSettingModel.updateSmscNumber(actionData, result => {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, 'updateSmscNumber, success');
            } else {
                HiLog.w(TAG, 'updateSmscNumber, fail');
            }
        });
    },

    /**
     * 分享短信中心dialog内选中的内容
     * @param actionData 参数
     * @param callback 回调
     * @return
     */
    shareSmsEnterSelectedText(actionData) {
        // 分享API目前未提供
        mSettingModel.shareSmsEnterSelectedText(actionData, result => {
            if (result.code == common.int.SUCCESS) {
                HiLog.i(TAG, 'shareSmsEnterSelectedText, success');
            } else {
            }
        });
    },

    /**
     * 通知信息整合开关、是否显示联系人头像开关的值
     */
    getSettingFlagForConvListPage() {
        let result: LooseObject = {
            isShowContactHeadIcon: false,
            hasAggregate: false,
            recallMessagesFlag: false,
        };
        mSettingModel.getSettingValue(settingValue => {
            if (settingValue.code === common.int.SUCCESS) {
                HiLog.i(TAG, 'getSettingFlagForConvListPage, Success');
                if (settingValue.abilityResult.isShowContactHeadIcon === common.bool.TRUE) {
                    result.isShowContactHeadIcon = true;
                }
                if (settingValue.abilityResult.hasAggregate == common.bool.TRUE) {
                    result.hasAggregate = true;
                }
                if (settingValue.abilityResult.recallMessagesFlag == common.bool.TRUE) {
                    result.recallMessagesFlag = true;
                }
            } else {
                HiLog.w(TAG, 'getSettingFlagForConvListPage, fail');
            }
        });
        return result;
    },

    /**
     * 判断是否需要送达报告
     *
     * @param {boolean} isMms 是否是彩信
     */
    judgeIsDeliveryReport(isMms) {
        let deliveryReportSwitch = preferences.getValueOfDeliveryReportSwitch();
        if (deliveryReportSwitch === common.DELIVERY_REPORTS.DISABLED) {
            return false;
        }
        // 如果是彩信和短息,直接返回true
        if (deliveryReportSwitch === common.DELIVERY_REPORTS.SMS_AND_MMS) {
            return true;
        }
        // 单独只有短信的时候，才有送达报告
        if (deliveryReportSwitch == common.DELIVERY_REPORTS.SMS && !isMms){
            return true;
        }
        // 单独只有彩信的时候，才有送达报告
        if (deliveryReportSwitch == common.DELIVERY_REPORTS.MMS && isMms){
            return true;
        }
        return false;
    },

    /**
     * 计算被选中的值
     * @param mmsList
     * @param isAllSelect
     */
    calculateChecked(simMessageList, isAllSelect){
        let count = 0;
        let checkedList = [];
        let result: LooseObject = {};
        let switchOff = false;
        for(let item of simMessageList) {
            // 如果全选
            if(isAllSelect || item.isCbChecked) {
                switchOff = true;
            }
            if(switchOff) {
                checkedList.push(item);
                count++;
            }
            switchOff = false;
        }
        result.count = count;
        result.checkedList = checkedList;
        return result;
    },
}