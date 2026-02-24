# SpeedLab 🏎️

SpeedLab, aracınızın performansını ve ivmelenmesini ölçmek için geliştirilmiş bir iOS uygulamasıdır. Konum (GPS) ve hareket (Motion) sensörlerini bir arada kullanarak 0-100 km/s hızlanma gibi telemetri verilerini gerçek zamanlı olarak takip eder ve elde ettiği verileri kaydeder.
<img src="https://github.com/user-attachments/assets/380d8438-74a1-42e0-91df-7eaf9cfb191c" width="250">
<img src="https://github.com/user-attachments/assets/ce3905e8-2009-4e58-a577-95f261e24c79" width="250">
<img src="https://github.com/user-attachments/assets/e16a9160-c6f6-4c81-9192-b78e9fed2bc1" width="250">


## Özellikler ✨
- **Performans Ölçümü:** 0-100 km/s hızlanma süresi gibi ölçümleri otomatik ve hassas olarak gerçekleştirir.
- **Sürüş Geçmişi:** Önceki testlerinizi detaylı olarak (Drive History) kaydeder ve listeler.
- **Gerçek Zamanlı Sensör Verileri:** Anlık hız (GPS ile) ve İvme/G-Force (Motion sensörü ile) takibi sağlar.
- **Modern Arayüz:** SwiftUI tabanlı, standartlara uygun pürüzsüz ve kullanıcı dostu arayüz.

## Teknolojiler ve Mimari 🛠️
- **Dil:** Swift
- **Kullanıcı Arayüzü (UI):** SwiftUI
- **Mimari Yaklaşım:** Feature-First & MVVM
  - `Core`: Uygulama genelinde paylaşılan donanım entegrasyonları, yöneticiler ve veri kaynakları (`LocationManager`, `MotionManager`, `PerformanceRepository`).
  - `Features`: Bağımsız, ekran ve özellik bazlı modüller (`Home`, `Drive`, `History`).
- **Framework'ler:**
  - `CoreLocation`: GPS üzerinden hız okumaları.
  - `CoreMotion`: İvmeölçer yardımıyla anlık hareket yakalama.

## Başlarken 🚀
1. Bu depoyu yerel bilgisayarınıza klonlayın.
2. `SpeedLab.xcodeproj` dosyasını Xcode üzerinden açın.
3. Uygulamayı fiziksel bir iOS cihazına yükleyin.
   > **Not:** Konum ve ivme ölçümleri gerektirdiği için uygulamanın tam anlamıyla test edilmesi ancak *fiziksel bir cihazda* mümkündür. Simülatör sensör özellikleri kısıtlıdır.
4. Xcode üzerinde cihazınızı seçip projeyi çalıştırın (`Cmd + R`).

## Kurulum / Gereksinimler
- Xcode 15+ 
- iOS 16.0 veya daha yeni bir sürüm.
- Swift 5.0+ 
