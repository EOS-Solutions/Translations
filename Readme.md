# **Translations**

## Translation files for EOS-Solutions Business Central extensions.

The files in each application folder can be used to fix errors or complete missing translations.

This xlif-files can be opened and modified with specific Xlif-Editors. 

* EOS Solutions internals and authorized partners can install and use ***EOS Xliff Editor***  
  Install the editor retrieving it from internal feeds.  
  In GitHub Repo *Defaults* you can find a predefined configuration file to use with the EOS Xliff Editor

* Others can use e.g. Microsoft ***Multilingual Editor*** ( ["Multilingual app toolkit 4.0 Editor"](https://developer.microsoft.com/en-us/windows/downloads/multilingual-app-toolkit/) )  
or  any other compatible Xliff Editor 

All fixes and modifications will be reviewed by EOS before they're inserted in new official extension version!

There are several official master branches in this repository. They reflect the supported BC versions. So you can find :
- master-bc14
- master-bc22
- master-bc23
- master-bc24

No pure "master" branch is present/used!

Nobody is allowed to work directly on this master branches. You have to 
1. locally clone a specific master version branch
2. make all the changes you think (add, remove, modify)
3. commit the changes
4. push the commits to GitHub repo "Translations"
5. create a new PullRequest 

Authorized EOS-Solutions developers review, accept or reject all or part of your changes in the PullRequest.  
All accepted changes will then be included in the official EOS-Solutions extension repo.  
A new app version is then builded and published. This last step will also merge these accepted changes into the master-bcxx branch of the "Translations" repository.  
If applicable, after evaluation by developer, changes can also be inserted in other managed BC versions.  

## Missing languages
You can create your own Xliff file starting from the "*.g.xlf" file and include it in your own PTE extension.  
  
Alternatively you can duplicate an existing language file rename it with the new correct wished language code ( e.g.  "applicationname.xx-XX.xlf") open the file with a common **text-editor** (e.g. Notepad) and fix present language code with the selected new one.
Do this searching the attribute *target-language* of the ***FILE*** node (normally the 3rd line from top). 

Here an example:

      <?xml version="1.0" encoding="utf-8"?>
      <xliff version="1.2" xmlns="urn:oasis:names:tc:xliff:document:1.2">
        <file datatype="xml" source-language="en-US" target-language="xx-XX">
          <body>
          <group id="body">

Now Save and close the new xlf-file. 
You are ready to use it with your favorite xliff editor and translate the extension objects to new language.  
Attention: doing so the copied xlf file probably already contains translated objects from original/source xlf file!   
