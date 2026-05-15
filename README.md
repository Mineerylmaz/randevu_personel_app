````md
<div align="center">

# Randevu Personel Uygulaması

Modern, çok kiracılı (multi-tenant) randevu sisteminin personel yönetim uygulaması.

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Node.js-Express-339933?style=for-the-badge&logo=node.js&logoColor=white" />
  <img src="https://img.shields.io/badge/MySQL-Database-4479A1?style=for-the-badge&logo=mysql&logoColor=white" />
  <img src="https://img.shields.io/badge/JWT-Authentication-black?style=for-the-badge&logo=jsonwebtokens" />
</p>

<br>

<img src="screenshots/cover.png" width="100%" />

</div>

---

# Proje Hakkında

Randevu Personel Uygulaması, işletmelerde çalışan personellerin randevu süreçlerini yönetebilmesi için geliştirilmiş modern bir Flutter uygulamasıdır.

Uygulama sayesinde personeller:

- Kendilerine gelen randevuları görüntüleyebilir
- Randevu onaylayabilir veya iptal edebilir
- Çalışma saatlerini görüntüleyebilir
- Profil bilgilerini düzenleyebilir
- Profil fotoğrafı yükleyebilir
- Şifre değiştirebilir
- Kendilerine yapılan yorum ve puanları görüntüleyebilir

Mobil arayüz Flutter ile geliştirilmiş olup backend tarafında Node.js + Express.js ve MySQL kullanılmıştır.

---

# Özellikler

## Randevu Yönetimi

- Yaklaşan randevuları listeleme
- Bekleyen randevuları onaylama
- Randevu iptal etme
- Durum bazlı filtreleme sistemi
- Detaylı randevu görüntüleme

---

## Profil Sistemi

- Profil fotoğrafı yükleme
- Profil bilgilerini düzenleme
- Şifre değiştirme
- Kalıcı kullanıcı oturumu

---

## Çalışma Saatleri

- Personel çalışma günlerini görüntüleme
- Çalışma saatlerini listeleme
- Müsaitlik yönetimi altyapısı

---

## Yorum & Puan Sistemi

- Müşteri yorumlarını görüntüleme
- Ortalama puan sistemi
- Personel geri bildirim ekranı

---

# Kullanılan Teknolojiler

| Teknoloji | Açıklama |
|---|---|
| Flutter | Mobil uygulama |
| Dart | Uygulama dili |
| Node.js | Backend |
| Express.js | REST API |
| MySQL | Veritabanı |
| JWT | Kimlik doğrulama |
| Dio | HTTP istemcisi |
| SharedPreferences | Token saklama |

---

# Mimari Yapı

```text
Flutter Uygulaması
        ↓
REST API (Express.js)
        ↓
JWT Authentication Middleware
        ↓
MySQL Veritabanı
````

---

# Uygulama Görselleri

## Giriş Ekranı

<img width="415" height="712" alt="image" src="https://github.com/user-attachments/assets/34784a8b-7bff-4977-843e-91ecd73a0664" />


---

## Ana Sayfa

<img width="325" height="690" alt="image" src="https://github.com/user-attachments/assets/99bb5def-1104-47cd-b929-9dd80a2b1b89" />


---


## Profil Sayfası

<img width="348" height="731" alt="image" src="https://github.com/user-attachments/assets/99569f2d-71be-4bb1-b6ba-f68ca2ec9fcf" />


---

## Yorum & Puanlar

<img width="351" height="727" alt="image" src="https://github.com/user-attachments/assets/22201de5-ec41-42ef-bc97-44e389b5338b" />


---

# Klasör Yapısı

```bash
lib/
 ├── core/
 ├── features/
 │    ├── auth/
 │    ├── appointments/
 │    ├── profile/
 │    ├── reviews/
 │    └── working_hours/
 ├── widgets/
 └── main.dart
```

---

# Backend

Mobil uygulama, özel olarak geliştirilen REST API ile haberleşmektedir.

Backend tarafında:

* Express.js
* MySQL
* JWT Authentication
* Multi-tenant yapı
* Middleware tabanlı güvenlik sistemi

kullanılmıştır.

---

# Gelecekte Planlanan Özellikler

* Push notification sistemi
* Gerçek zamanlı güncellemeler
* Gelişmiş istatistik ekranları
* Takvim entegrasyonları
* Dark mode
* Çoklu dil desteği

---

# Geliştirici

<div align="center">

### Mine Eryılmaz

Flutter • Node.js • MySQL

</div>
```
