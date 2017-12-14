#!/bin/sh
set -e

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

case "${TARGETED_DEVICE_FAMILY}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\""
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\""
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\""
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH"
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "MatrixKit/MatrixKit/Controllers/MXKAccountDetailsViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKAttachmentsViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKAuthenticationViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKCallViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKContactDetailsViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKContactListViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKCountryPickerViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKLanguagePickerViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKRecentListViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKRoomMemberDetailsViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKRoomMemberListViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKRoomSettingsViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKRoomViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKSearchViewController.xib"
  install_resource "MatrixKit/MatrixKit/Views/Account/MXKAccountTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/Authentication/MXKAuthInputsEmailCodeBasedView.xib"
  install_resource "MatrixKit/MatrixKit/Views/Authentication/MXKAuthInputsPasswordBasedView.xib"
  install_resource "MatrixKit/MatrixKit/Views/Contact/MXKContactTableCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/DeviceView/MXKDeviceView.xib"
  install_resource "MatrixKit/MatrixKit/Views/EncryptionInfoView/MXKEncryptionInfoView.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKCollectionViewCell/MXKMediaCollectionViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKEventDetailsView.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKPieChartHUD.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKRoomCreationView.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithButton.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelAndButton.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelAndImageView.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelAndMXKImageView.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelAndSlider.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelAndSubLabel.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelAndSwitch.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelAndTextField.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelTextFieldAndButton.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithPicker.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithSearchBar.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithTextFieldAndButton.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithTextView.xib"
  install_resource "MatrixKit/MatrixKit/Views/PushRule/MXKPushRuleCreationTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/PushRule/MXKPushRuleTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/ReadReceipts/MXKReadReceiptTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomEmptyBubbleTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomIncomingAttachmentBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomIncomingAttachmentWithoutSenderInfoBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomIncomingTextMsgBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomIncomingTextMsgWithoutSenderInfoBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomIOSOutgoingBubbleTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomOutgoingAttachmentBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomOutgoingAttachmentWithoutSenderInfoBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomOutgoingTextMsgBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomOutgoingTextMsgWithoutSenderInfoBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomInputToolbar/MXKRoomInputToolbarView.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomInputToolbar/MXKRoomInputToolbarViewWithHPGrowingText.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomInputToolbar/MXKRoomInputToolbarViewWithSimpleTextView.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomList/MXKInterleavedRecentTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomList/MXKPublicRoomTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomList/MXKRecentTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomMemberList/MXKRoomMemberTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomTitle/MXKRoomTitleView.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomTitle/MXKRoomTitleViewWithTopic.xib"
  install_resource "MatrixKit/MatrixKit/Views/Search/MXKSearchTableViewCell.xib"
  install_resource "$PODS_CONFIGURATION_BUILD_DIR/MatrixKit/MatrixKit.bundle"
  install_resource "MatrixSDK/MatrixSDK/Data/Store/MXCoreDataStore/MXCoreDataStore.xcdatamodeld"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "MatrixKit/MatrixKit/Controllers/MXKAccountDetailsViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKAttachmentsViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKAuthenticationViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKCallViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKContactDetailsViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKContactListViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKCountryPickerViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKLanguagePickerViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKRecentListViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKRoomMemberDetailsViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKRoomMemberListViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKRoomSettingsViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKRoomViewController.xib"
  install_resource "MatrixKit/MatrixKit/Controllers/MXKSearchViewController.xib"
  install_resource "MatrixKit/MatrixKit/Views/Account/MXKAccountTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/Authentication/MXKAuthInputsEmailCodeBasedView.xib"
  install_resource "MatrixKit/MatrixKit/Views/Authentication/MXKAuthInputsPasswordBasedView.xib"
  install_resource "MatrixKit/MatrixKit/Views/Contact/MXKContactTableCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/DeviceView/MXKDeviceView.xib"
  install_resource "MatrixKit/MatrixKit/Views/EncryptionInfoView/MXKEncryptionInfoView.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKCollectionViewCell/MXKMediaCollectionViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKEventDetailsView.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKPieChartHUD.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKRoomCreationView.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithButton.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelAndButton.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelAndImageView.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelAndMXKImageView.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelAndSlider.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelAndSubLabel.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelAndSwitch.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelAndTextField.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithLabelTextFieldAndButton.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithPicker.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithSearchBar.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithTextFieldAndButton.xib"
  install_resource "MatrixKit/MatrixKit/Views/MXKTableViewCell/MXKTableViewCellWithTextView.xib"
  install_resource "MatrixKit/MatrixKit/Views/PushRule/MXKPushRuleCreationTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/PushRule/MXKPushRuleTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/ReadReceipts/MXKReadReceiptTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomEmptyBubbleTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomIncomingAttachmentBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomIncomingAttachmentWithoutSenderInfoBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomIncomingTextMsgBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomIncomingTextMsgWithoutSenderInfoBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomIOSOutgoingBubbleTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomOutgoingAttachmentBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomOutgoingAttachmentWithoutSenderInfoBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomOutgoingTextMsgBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomBubbleList/MXKRoomOutgoingTextMsgWithoutSenderInfoBubbleCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomInputToolbar/MXKRoomInputToolbarView.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomInputToolbar/MXKRoomInputToolbarViewWithHPGrowingText.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomInputToolbar/MXKRoomInputToolbarViewWithSimpleTextView.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomList/MXKInterleavedRecentTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomList/MXKPublicRoomTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomList/MXKRecentTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomMemberList/MXKRoomMemberTableViewCell.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomTitle/MXKRoomTitleView.xib"
  install_resource "MatrixKit/MatrixKit/Views/RoomTitle/MXKRoomTitleViewWithTopic.xib"
  install_resource "MatrixKit/MatrixKit/Views/Search/MXKSearchTableViewCell.xib"
  install_resource "$PODS_CONFIGURATION_BUILD_DIR/MatrixKit/MatrixKit.bundle"
  install_resource "MatrixSDK/MatrixSDK/Data/Store/MXCoreDataStore/MXCoreDataStore.xcdatamodeld"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
