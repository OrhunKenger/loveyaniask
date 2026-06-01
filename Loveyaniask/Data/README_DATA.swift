//
//  Data Katmanı
//  Loveyaniask
//
//  Domain'deki Repository protokollerinin GERÇEK implementasyonları burada.
//  Veriyi nereden alacağımızı bilir (local, UserDefaults, ileride backend/API).
//
//  İçerir:
//   - Repositories/  : Domain protokollerini uygulayan sınıflar
//   - DataSources/   : Ham veri kaynakları (local store, API client vb.)
//
//  Bağımlılık yönü: Data --> Domain (Domain hiçbir zaman Data'yı bilmez).
//
