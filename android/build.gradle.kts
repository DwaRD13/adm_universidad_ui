allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// flutter_plugin_android_lifecycle (arrastrado por file_picker) exige compileSdk 36+.
// El compileSdk por defecto de este Flutter SDK sigue siendo 34 para los modulos de
// los plugins, aunque el modulo :app ya lo tenga en 36 — hay que forzarlo aqui para
// que aplique a todos los subproyectos, plugins incluidos.
// Este bloque tiene que ir ANTES del evaluationDependsOn(":app") de abajo: ese
// evaluationDependsOn evalua :app en el acto y despues ya no se le puede registrar
// un afterEvaluate ("Cannot run Project.afterEvaluate(Action) when the project is
// already evaluated").
subprojects {
    afterEvaluate {
        extensions.findByType(com.android.build.gradle.BaseExtension::class.java)?.apply {
            compileSdkVersion(36)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
