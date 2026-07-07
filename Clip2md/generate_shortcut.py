#!/usr/bin/env python3
import sys
import plistlib

def main():
    if len(sys.argv) < 3:
        print("Usage: generate_shortcut.py <absolute_path_to_save_markdown.sh> <output_path.shortcut>")
        sys.exit(1)

    script_path = sys.argv[1]
    output_path = sys.argv[2]

    # We use a structure representing a valid Apple Shortcut that runs a shell script.
    # The action identifier 'is.workflow.actions.runshellscript' executes the command.
    shortcut_data = {
        "WFWorkflowMinimumClientVersionString": "900",
        "WFWorkflowMinimumClientVersion": 900,
        "WFWorkflowClientVersion": "2600.5",
        "WFWorkflowTypes": [
            "NCWidget",
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
        "WFWorkflowActions": [
            {
                "WFWorkflowActionIdentifier": "is.workflow.actions.runshellscript",
                "WFWorkflowActionParameters": {
                    "ScriptActionText": f'bash "{script_path}"',
                    "Shell": "/bin/zsh"
                }
            }
        ],
        "WFWorkflowIcon": {
            "WFWorkflowIconGlyphNumber": 59511, # Icon shape
            "WFWorkflowIconStartColor": 431817727 # Icon color
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
