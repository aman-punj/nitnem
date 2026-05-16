] Transforming lifecycle-process-2.7.0.aar (androidx.lifecycle:lifecycle-process:2.7.0) with JetifyTransform
[        ] Transforming lifecycle-process-2.7.0.aar (androidx.lifecycle:lifecycle-process:2.7.0) with ExtractAarTransform
[        ] Transforming sav
[        ] Missing class com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener (referenced from: void
io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager.<init>(android.content.Context, io.flutter.embedding.engine.FlutterJNI) and 2 other contexts)
[   +1 ms] Missing class com.google.android.play.core.tasks.OnFailureListener (referenced from: void
io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager.installDeferredComponent(int, java.lang.String))
[   +1 ms] Missing class com.google.android.play.core.tasks.OnSuccessListener (referenced from: void
io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager.installDeferredComponent(int, java.lang.String))
[        ] Missing class com.google.android.play.core.tasks.Task (referenced from: void
io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager.installDeferredComponent(int, java.lang.String) and 1 other context)
[   +1 ms]              at com.android.tools.r8.internal.Me0.a(R8_8.9.32_b544fddaa3c5775749f5287a4ea253aa22d60a2ae31101691f9da7bdcc5515a9:27)
[   +5 ms]              at com.android.tools.r8.shaking.M.a(R8_8.9.32_b544fddaa3c5775749f5287a4ea253aa22d60a2ae31101691f9da7bdcc5515a9:1982)
[   +1 ms]              ... 45 more
[   +1 ms]      Caused by: [CIRCULAR REFERENCE: com.android.tools.r8.internal.g: Missing class com.google.android.play.core.splitcompat.SplitCompatApplication (referenced from: void
io.flutter.embedding.android.FlutterPlayStoreSplitApplication.<init>() and 2 other contexts)
[   +1 ms] Missing class com.google.android.play.core.splitinstall.SplitInstallException (referenced from: void
io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager.lambda$installDeferredComponent$1(int, java.lang.String, java.lang.Exception))
[   +2 ms] Missing class com.google.android.play.core.splitinstall.SplitInstallManager (referenced from: com.google.android.play.core.splitinstall.SplitInstallManager
io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager.splitInstallManager and 5 other contexts)
[   +2 ms] Missing class com.google.android.play.core.splitinstall.SplitInstallManagerFactory (referenced from: void
io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager.<init>(android.content.Context, io.flutter.embedding.engine.FlutterJNI))
[        ] Missing class com.google.android.play.core.splitinstall.SplitInstallRequest$Builder (referenced from: void
io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager.installDeferredComponent(int, java.lang.String))
[        ] Missing class com.google.android.play.core.splitinstall.SplitInstallRequest (referenced from: void
io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager.installDeferredComponent(int, java.lang.String))
[   +1 ms] Missing class com.google.android.play.core.splitinstall.SplitInstallSessionState (referenced from: void
io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager$FeatureInstallStateUpdatedListener.onStateUpdate(com.google.android.play.core.splitinstall.SplitInstallS
essionState) and 1 other context)
[   +2 ms] Missing class com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener (referenced from: void
io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager.<init>(android.content.Context, io.flutter.embedding.engine.FlutterJNI) and 2 other contexts)
[   +1 ms] Missing class com.google.android.play.core.tasks.OnFailureListener (referenced from: void
io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager.installDeferredComponent(int, java.lang.String))
[   +1 ms] Missing class com.google.android.play.core.tasks.OnSuccessListener (referenced from: void
io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager.installDeferredComponent(int, java.lang.String))
[        ] Missing class com.google.android.play.core.tasks.Task (referenced from: void
io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager.installDeferredComponent(int, java.lang.String) and 1 other context)]
[   +1 ms] BUILD FAILED in 59s
[   +1 ms] 667 actionable tasks: 35 executed, 632 up-to-date
[        ] Watched directory hierarchies: [D:\Dev\src\flutter\packages\flutter_tools\gradle, D:\Dev\Projects\flutter_projects\nitnem\mobile_app\android]
[  +58 ms] Running Gradle task 'assembleRelease'... (completed in 70.5s)
[  +27 ms] "flutter apk" took 81,358ms.
[ +162 ms] Gradle task assembleRelease failed with exit code 1
[  +17 ms] 
           #0      throwToolExit (package:flutter_tools/src/base/common.dart:34:3)
           #1      AndroidGradleBuilder.buildGradleApp (package:flutter_tools/src/android/gradle.dart:600:7)
           <asynchronous suspension>
           #2      AndroidGradleBuilder.buildApk (package:flutter_tools/src/android/gradle.dart:239:5)
           <asynchronous suspension>
           #3      BuildApkCommand.runCommand (package:flutter_tools/src/commands/build_apk.dart:131:5)
           <asynchronous suspension>
           #4      FlutterCommand.run.<anonymous closure> (package:flutter_tools/src/runner/flutter_command.dart:1581:27)
           <asynchronous suspension>
           #5      AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
           <asynchronous suspension>
           #6      CommandRunner.runCommand (package:args/command_runner.dart:212:13)
           <asynchronous suspension>
           #7      FlutterCommandRunner.runCommand.<anonymous closure> (package:flutter_tools/src/runner/flutter_command_runner.dart:503:9)
           <asynchronous suspension>
           #8      AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
           <asynchronous suspension>
           #9      FlutterCommandRunner.runCommand (package:flutter_tools/src/runner/flutter_command_runner.dart:438:5)
           <asynchronous suspension>
           #10     run.<anonymous closure>.<anonymous closure> (package:flutter_tools/runner.dart:98:11)
           <asynchronous suspension>
           #11     AppContext.run.<anonymous closure> (package:flutter_tools/src/base/context.dart:154:19)
           <asynchronous suspension>
           #12     main (package:flutter_tools/executable.dart:101:3)
           <asynchronous suspension>
           