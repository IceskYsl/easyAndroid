MsgBox, 4,, 是否已下载并解压JDK?
        IfMsgBox Yes
        {
                FileSelectFolder, JDK ,,,选择JDK文件夹
        }
        else
        {
                if (A_Is64bitOS)
                {
                        MsgBox,,, 检测到64位系统 正在下载对应JDK,1
                        JDKDownloadUrl=http://download.oracle.com/otn-pub/java/jdk/7u45-b18/jdk-7u45-windows-x64.exe
                }
                else 
                {
                        MsgBox,,, 检测到32位系统 正在下载对应JDK,1
                        JDKDownloadUrl=http://download.oracle.com/otn-pub/java/jdk/7u45-b18/jdk-7u45-windows-i586.exe
                }
                UrlDownloadToFile, %JDKDownloadUrl%, jdk.exe
                Msgbox ,,,下载完成 开始安装,1
                RunWait, jdk.exe
                FileSelectFolder, JDK ,,,选择JDK安装目录
                FileDelete, jdk.exe
        }

MsgBox, 4,, 是否已下载并解压ADT(包括android SDK 和 eclipse)?
        IfMsgBox Yes
        {
                FileSelectFolder, ASH ,,,选择Android SDK文件夹 `n请确认该文件夹包含"platform-tools"文件夹
                Msgbox ,,,启动eclipse以完成最后配置`n`n请选择eclipse.exe`n`n配置完成后请关闭eclipse,3
                FileSelectFile, eclipseExe,,,选择eclipse.exe,
                Runwait, %eclipseExe%
        }
        else
        {
                FileSelectFolder, ASH ,,,选择Andoird SDK下载安装目录(将作为ANDROID_SDK_HOME)
                FileSelectFolder, EclipseFolder ,,,选择Eclipse下载安装目录
                if (A_Is64bitOS)
                {
                        MsgBox,,, 检测到64位系统 正在下载对应ADT,1
                        SDKDownloadUrl=http://dl.google.com/android/adt/adt-bundle-windows-x86_64-20131030.zip
                        folder=adt-bundle-windows-x86_64-20131030
                }
                else 
                {
                        MsgBox,,, 检测到32位系统 正在下载对应ADT,1
                        SDKDownloadUrl=http://dl.google.com/android/adt/adt-bundle-windows-x86-20131030.zip
                        folder=adt-bundle-windows-x86-20131030
                }
                UrlDownloadToFile, %SDKDownloadUrl%, adt.zip
                Msgbox ,,,下载完成 开始解压...,1
                workingFolder = %A_WorkingDir%\adt
                downloadFile = %A_WorkingDir%\adt.zip
                Unz(downloadFile, workingFolder)
                FileDelete, adt.zip
                MsgBox ,,, 解压完成,1
                FileMoveDir, adt\%folder%\eclipse, %EclipseFolder%, 2
                FileMoveDir, adt\%folder%\sdk, %ASH%, 2
                FileCopy, adt\%folder%\SDK Manager.exe, %ASH%, 1
                Msgbox ,,, 安装完成 启动eclipse以完成最后配置 配置完成后请关闭eclipse,1
                RunWait, %EclipseFolder%\eclipse.exe
        }

MsgBox, 4,, 是否需要检查并自动配置环境变量?
        IfMsgBox Yes 
        {
        path = %ASH%\tools`;%ASH%\platform-tools`;%JDK%\bin
        classpath = .`;%JDK%\lib

        Msgbox, %path%
        MsgBox, %classpath%

        Runwait rundll32.exe shell32.dll`,Control_RunDLL sysdm.cpl`,`,3
        Send, {Tab 3}{Enter}{Tab 5}

        setEnvVar("ANDROID_SDK_HOME", ASH)
        setEnvVar("JAVA_HOME", JDK)
        setEnvVar("path", path)
        setEnvVar("classpath", classpath)
        Send, {Tab 3}{Enter}{Tab}{Enter}

        MsgBox, 4,, 需要注销并重新登录以应用改变 现在注销?
                IfMsgBox Yes
                    Shutdown, 0
        }

setEnvVar(envVarName, envVarValue){
        EnvGet, pEnvVar, %envVarName%
        if (InStr(pEnvVar, envVarValue))
        {
                MsgBox,,, %envVarValue% already exist, 1
        }
        else 
        {
                Send, {Enter}
                SendInput, %envVarName%
                Send, {Tab}
                SendInput, %pEnvVar%`;%envVarValue%
                Send, {Enter}
        }
}

Unz(sZip, sUnz)
{
    fso := ComObjCreate("Scripting.FileSystemObject")
    If Not fso.FolderExists(sUnz)
       FileCreateDir, %sUnz% 
    psh  := ComObjCreate("Shell.Application")
    zippedItems := psh.Namespace( sZip ).items().count
    psh.Namespace( sUnz ).CopyHere( psh.Namespace( sZip ).items, 4|16 )
    Loop {
        sleep 50
        unzippedItems := psh.Namespace( sUnz ).items().count
        IfEqual,zippedItems,%unzippedItems%
            break
    }
}