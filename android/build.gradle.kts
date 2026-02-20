plugins {
    id("com.android.application") apply false
    id("com.android.library") apply false
    id("org.jetbrains.kotlin.android") apply false
    // AÑADE ESTA LÍNEA AQUÍ PARA FIREBASE:
    id("com.google.gms.google-services") version "4.4.0" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}



tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}