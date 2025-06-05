# Encode and Decode Packages

## WHY

I wanted to archive a big ZIP file on Github. But as you can imagine, github prevents the usage of repositories to archive sizeable binaries like movies, audio files, zip files, etc...

## Concept

This is a script that will create a encrypted archive, then split it in parts of specified sizes (like with 7z) but in TEXT format with files suffixed in ```.cpp``` so GITHUB thinks this is source code.


### Decode 

```powershell
./scripts/Decode.ps1
```

![decode](img/decode.gif)

### Encode

```powershell
./scripts/Encode.ps1
```

![encode](img/encode.gif)