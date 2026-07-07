#!/usr/bin/env python3
import sys
import plistlib

def main():
    if len(sys.argv) < 2:
        print("Usage: generate_shortcut.py <output_path.shortcut>")
        sys.exit(1)

    output_path = sys.argv[1]

    # Native Shortcut structure representing:
    # 1. Get Clipboard
    # 2. Make Markdown from Shortcut Input
    # 3. Set name of Markdown to clipboard.md
    # 4. Save Renamed Item
    shortcut_data = {
        "WFWorkflowMinimumClientVersionString": "900",
        "WFWorkflowMinimumClientVersion": 900,
        "WFWorkflowClientVersion": "2600.5",
        "WFWorkflowTypes": [
            "QuickActions"
        ],
        "WFWorkflowInputContentItemClasses": [
            "WFAppStoreAppContentItem",
            "WFArticleContentItem",
            "WFContactContentItem",
            "WFDateContentItem",
            "WFEmailAddressContentItem",
            "WFFolderContentItem",
            "WFGenericFileContentItem",
            "WFImageContentItem",
            "WFiTunesProductContentItem",
            "WFLocationContentItem",
            "WFDCMapsLinkContentItem",
            "WFAVAssetContentItem",
            "WFPDFContentItem",
            "WFPhoneNumberContentItem",
            "WFRichTextContentItem",
            "WFSafariWebPageContentItem",
            "WFStringContentItem",
            "WFURLContentItem"
        ],
        "WFWorkflowNoInputBehavior": {
            "Name": "WFWorkflowNoInputBehaviorGetClipboard",
            "Parameters": {}
        },
        "WFWorkflowActions": [
            {
                "WFWorkflowActionIdentifier": "is.workflow.actions.getclipboard",
                "WFWorkflowActionParameters": {
                    "UUID": "E9E9C7E5-3A26-4444-9B05-9D270AD3D2B0"
                }
            },
            {
                "WFWorkflowActionIdentifier": "is.workflow.actions.getmarkdownfromrichtext",
                "WFWorkflowActionParameters": {
                    "UUID": "B9057B43-A109-4C8D-9818-D7270AD3D2B5",
                    "WFInput": {
                        "Value": {
                            "Type": "ExtensionInput"
                        },
                        "WFSerializationType": "WFTextTokenAttachment"
                    }
                }
            },
            {
                "WFWorkflowActionIdentifier": "is.workflow.actions.setitemname",
                "WFWorkflowActionParameters": {
                    "UUID": "2EE99C2A-18D3-48FA-97E4-500D06940026",
                    "WFInput": {
                        "Value": {
                            "OutputName": "Markdown from Rich Text",
                            "OutputUUID": "B9057B43-A109-4C8D-9818-D7270AD3D2B5",
                            "Type": "ActionOutput"
                        },
                        "WFSerializationType": "WFTextTokenAttachment"
                    },
                    "WFName": "clipboard.md"
                }
            },
            {
                "WFWorkflowActionIdentifier": "is.workflow.actions.documentpicker.save",
                "WFWorkflowActionParameters": {
                    "UUID": "F4B4E76C-100D-4C67-A281-229202613C2F",
                    "WFInput": {
                        "Value": {
                            "OutputName": "Renamed Item",
                            "OutputUUID": "2EE99C2A-18D3-48FA-97E4-500D06940026",
                            "Type": "ActionOutput"
                        },
                        "WFSerializationType": "WFTextTokenAttachment"
                    },
                    "WFAskWhereToSave": True
                }
            }
        ],
        "WFWorkflowIcon": {
            "WFWorkflowIconGlyphNumber": 59511, # Document/file icon
            "WFWorkflowIconStartColor": 431817727 # Blue color
        }
    }

    try:
        with open(output_path, "wb") as f:
            plistlib.dump(shortcut_data, f, fmt=plistlib.FMT_BINARY)
        print(f"Generated unsigned shortcut at: {output_path}")
    except Exception as e:
        print(f"Failed to generate shortcut file: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
