# 🌿 Kozmetik İçerik Analiz Uygulaması

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue) ![Dart](https://img.shields.io/badge/Dart-3.0%2B-blue) ![State Management](https://img.shields.io/badge/State%20Management-Provider-orange) ![License](https://img.shields.io/badge/License-MIT-green)

## 📖 Proje Hakkında

Bu proje, Mobil Programlama dersi kapsamında geliştirilmiş bir **Kozmetik Ürün İçerik Analiz** uygulamasıdır. Kullanıcılar, kozmetik ürünlerin barkodunu taratarak veya içerik ismini aratarak; ürünün **risk seviyesini**, **cilt tipi uyumluluğunu** ve **ne işe yaradığını** anında öğrenebilirler.

Proje, **Temiz Mimari (Clean Architecture)** prensiplerine uygun olarak, **Provider** ile durum yönetimi ve **Asenkron** yapılar kullanılarak geliştirilmiştir.

---

## ✨ Özellikler

* **🔍 Akıllı Arama:** 60+ farklı kozmetik bileşenini isme göre anlık filtreleme.
* **📷 Barkod Tarama:** Cihaz kamerasını kullanarak ürün barkodunu okuma ve analiz etme.
* **⚠️ Risk Analizi:** İçerikleri risk seviyelerine göre renklendirme (Yeşil: Düşük, Turuncu: Orta, Kırmızı: Yüksek).
* **📱 Modern Arayüz:** Kullanıcı dostu, responsive ve özel widget'larla (Custom Widget) desteklenmiş tasarım.
* **🔐 Güvenli Akış:** Splash -> Login -> Home ekran geçişleri.

---

## 📸 Ekran Görüntüleri

| Giriş Ekranı | Ana Sayfa | Barkod Tarama | Ayarlar Sayfası | Çıkış Ekranı | Görüntü Yükleme | İçerik Tarama | Kayıt Sayfası | Profil Sayfası | Sanal Kamera | Ürün İçeriği | 
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: || :---: | :---: | :---: |
| <img src="Girissayfasi.jpg" width="200" /> | <img src="Anaekran.jpg" width="200" /> | <img src="barkodtarama.jpg" width="200" /> | <img src="ayarlarsayfasi" width="200" /> | <img src="cikis.jpg" width="200" /> | <img src="galeridenyukleme.png" width="200" /> | <img src="içeriktarama.jpg" width="200" /> | <img src="Kayitsayfasi.jpg" width="200" /> |<img src="profilsayfasi.jpg" width="200" /> | <img src="sanalkamera.jpg" width="200" /> | <img src="ürünicerigi.jpg" width="200" /> | 

*(Ekran görüntüleri `screenshots` klasöründe yer almaktadır.)*

---

## 🛠️ Teknik Yetkinlikler (Sınav Kriterleri)

Bu proje, dersin değerlendirme kriterlerini tam olarak karşılayacak şekilde tasarlanmıştır:

### 1. State Management (Durum Yönetimi)
* **Provider Paketi:** Uygulamanın tüm veri akışı (`AnalysisProvider`) merkezi olarak yönetilmektedir.
* `setState` karmaşasından kaçınılarak performanslı bir yapı kurulmuştur.

### 2. Asenkron Yapılar (Async/Await)
* Barkod okuma ve veritabanı sorgulama işlemleri `Future` ve `async/await` yapıları ile yönetilmiştir.
* İşlem sırasında kullanıcıya `CircularProgressIndicator` ile geri bildirim verilir.

### 3. Custom Widget (Özel Widget)
* Kod tekrarını önlemek için `IngredientCard` gibi yeniden kullanılabilir widget'lar oluşturulmuştur.

### 4. Temiz Kod Mimarisi
Proje klasörleri işlevlerine göre ayrılmıştır:
* `lib/models`: Veri modelleri.
* `lib/providers`: Mantık katmanı.
* `lib/screens`: Arayüz sayfaları.
* `lib/widgets`: Parçalanmış widget'lar.
* `lib/common`: Sabitler ve renkler (`AppColors`).

---

## 🚀 Kurulum ve Çalıştırma

Projeyi yerel ortamınızda çalıştırmak için:

1.  **Gerekli paketleri yükleyin:**
    ```bash
    flutter pub get
    ```

2.  **Uygulamayı başlatın:**
    ```bash
    flutter run
    ```

---

**Geliştirici:** [Adın Soyadın]
**Ders:** Mobil Programlama