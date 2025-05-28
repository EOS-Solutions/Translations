# **Translations**

This repository contains updated translations from EOS Solutions apps, automatically updated when we update them in the source code.

We currently do not accept pull requests to this repository.

## How to Edit Translation Files for Business Central extensions

The files in each application folder can be used to fix errors or complete missing translations.

These XLIFF files can be opened and modified with specific XLIFF editors. 

* EOS Solutions internals and authorized partners can install and use ***Gordon XLIFF Editor***.
  Install the editor retrieving it from ***EOS Gordon Installer*** ( ["EOS Gordon Installer"](https://eos-solutions.github.io/Gordon/) )
  
  In GitHub Repo *Defaults* (["Defaults"](https://github.com/EOS-Solutions/Defaults)), you can find a predefined configuration file to use with the ***Gordon XLIFF Editor***

* Others can use, for example, Microsoft ***Multilingual App Toolkit Editor*** ( ["Multilingual app toolkit 4.0 Editor"](https://developer.microsoft.com/en-us/windows/downloads/multilingual-app-toolkit/) ) or any other compatible Xliff Editor.

There are some official master branches in this repository. So you can find:
- master-bc25 (Business Central 2024 Wave 2)
- master-bc26 (Business Central 2025 Wave 1)

No pure "master" branch is present/used!

## Missing languages
You can create your own XLIFF file based on the "*.g.xlf" file and include it in your own PTE extension.  
  
Alternatively, you can duplicate an existing language file, rename it with the correct language code (e.g.  "applicationname.xx-XX.xlf"), open the file with a common **text-editor** (e.g. Notepad) and replace the existing language code with the selected new one.
Do this by searching the attribute *target-language* of the ***FILE*** node (normally the 3rd line from the top). 

Here is an example:

```
<?xml version="1.0" encoding="utf-8"?>
<xliff version="1.2" xmlns="urn:oasis:names:tc:xliff:document:1.2">
  <file datatype="xml" source-language="en-US" target-language="xx-XX">
    <body>
    <group id="body">
```

Now, save and close the new .xlf file. 
You are ready to use it with your favourite XLIFF editor and translate the extension objects to the new language.  
Note: when doing so, the copied .xlf file probably already contains translated objects from the original/source .xlf file!   

## Using the edited translations

The edited .xlf files can be used in your custom apps. Pick the .xlf file, place it in the translation folder and inside the file add the attribute `original` with the name of the app you want to edit the text.

Here is an example:

```
<?xml version="1.0" encoding="utf-8"?>
<xliff version="1.2" xmlns="urn:oasis:names:tc:xliff:document:1.2">
  <file datatype="xml" source-language="en-US" target-language="xx-XX" original="Data Security">
    <body>
```
