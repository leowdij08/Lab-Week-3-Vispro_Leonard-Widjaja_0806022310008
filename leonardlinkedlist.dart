import 'dart:async';
import 'dart:collection';
import 'dart:io';

// Kode ANSI untuk membersihkan layar, mengatur kursor, dan warna terminal
const String bersihkanLayar = "\x1B[2J\x1B[H";
const String sembunyikanKursor = "\x1B[?25l";
const String tampilkanKursor = "\x1B[?25h";
const String resetKursor = "\x1B[H"; 
const String resetWarna = "\x1B[0m";

// Warna-warna kustom yang akan digunakan dalam animasi
const List<String> warnaKustom = [
  "\x1B[32m", // Hijau
  "\x1B[33m", // Kuning
  "\x1B[36m", // Cyan
];

// Kelas untuk menyimpan karakter dan warnanya, sebagai bagian dari linked list
final class SimbolKarakter extends LinkedListEntry<SimbolKarakter> {
  String karakter;
  String warna;
  
  // Konstruktor untuk menginisialisasi karakter dan warna
  SimbolKarakter(this.karakter, {this.warna = resetWarna});
}

void main() {
  stdout.write("Masukkan nama kamu: ");
  String? inputNama = stdin.readLineSync() ?? ''; // Input nama dari pengguna

  // Mengambil ukuran terminal (lebar dan tinggi)
  final lebarTerminal = stdout.terminalColumns;
  final tinggiTerminal = stdout.terminalLines;
  final totalKarakterGrid = lebarTerminal * tinggiTerminal; 
  final String teksTampilan = inputNama.isNotEmpty ? inputNama : "PENGGUNA"; // Teks default jika tidak ada input

  // Membuat grid karakter dalam bentuk linked list untuk setiap baris
  final List<LinkedList<SimbolKarakter>> daftarGrid = List.generate(tinggiTerminal, (_) {
    final baris = LinkedList<SimbolKarakter>();
    for (int i = 0; i < lebarTerminal; i++) {
      baris.add(SimbolKarakter(' ')); // Mengisi grid dengan spasi
    }
    return baris;
  });

  int indeksSaatIni = 0; 
  bool selesaiMengetik = false;
  int indeksWarnaSaatIni = 0;

  // Fungsi untuk menampilkan grid di layar terminal
  void tampilkanGrid() {
    stdout.write(resetKursor); // Mengembalikan kursor ke posisi awal
    for (var baris in daftarGrid) {
      for (var simbolKarakter in baris) {
        stdout.write("${simbolKarakter.warna}${simbolKarakter.karakter}"); // Menampilkan karakter dengan warna
      }
    }
    stdout.write(resetWarna); // Mengembalikan warna ke default
  }

  // Fungsi animasi yang berjalan secara asinkron
  Future<void> mulaiAnimasi() async {
    // Fase 1: Mencetak teks di grid satu per satu
    while (indeksSaatIni < totalKarakterGrid && !selesaiMengetik) {
      int baris = (indeksSaatIni ~/ lebarTerminal) % tinggiTerminal; 
      int kolom = (indeksSaatIni % lebarTerminal); 

      var barisSaatIni = daftarGrid[baris];
      var simbolSaatIni = barisSaatIni.first;

      // Akses node berdasarkan kolom yang sedang diproses
      for (int i = 0; i < kolom; i++) {
        simbolSaatIni = simbolSaatIni.next!;
      }

      // Proses pencetakan karakter searah atau terbalik
      if ((baris % 2) == 0) {
        simbolSaatIni.karakter = teksTampilan[indeksSaatIni % teksTampilan.length];
      } else {
        int kolomTerbalik = lebarTerminal - 1 - kolom;
        simbolSaatIni = barisSaatIni.first;
        for (int i = 0; i < kolomTerbalik; i++) {
          simbolSaatIni = simbolSaatIni.next!;
        }
        simbolSaatIni.karakter = teksTampilan[indeksSaatIni % teksTampilan.length];
      }

      stdout.write(sembunyikanKursor); // Sembunyikan kursor saat animasi berjalan
      tampilkanGrid(); // Tampilkan grid dengan karakter yang baru
      indeksSaatIni++;

      await Future.delayed(Duration(milliseconds: 5)); // Tunggu selama 25ms sebelum karakter berikutnya

      if (indeksSaatIni >= totalKarakterGrid) {
        selesaiMengetik = true;
        indeksSaatIni = 0; 
      }
    }

    // Fase 2: Mengubah warna teks setelah seluruh teks tercetak
    while (selesaiMengetik && indeksSaatIni < totalKarakterGrid && indeksWarnaSaatIni < warnaKustom.length) {
      int baris = (indeksSaatIni ~/ lebarTerminal) % tinggiTerminal;
      int kolom = (indeksSaatIni % lebarTerminal);

      var barisSaatIni = daftarGrid[baris];
      var simbolSaatIni = barisSaatIni.first;

      // Akses node berdasarkan kolom yang sedang diproses
      for (int i = 0; i < kolom; i++) {
        simbolSaatIni = simbolSaatIni.next!;
      }

      // Ganti warna karakter sesuai dengan baris (searah atau terbalik)
      if ((baris % 2) == 0) {
        simbolSaatIni.warna = warnaKustom[indeksWarnaSaatIni % warnaKustom.length]; 
      } else {
        int kolomTerbalik = lebarTerminal - 1 - kolom;
        simbolSaatIni = barisSaatIni.first;
        for (int i = 0; i < kolomTerbalik; i++) {
          simbolSaatIni = simbolSaatIni.next!;
        }
        simbolSaatIni.warna = warnaKustom[indeksWarnaSaatIni % warnaKustom.length]; 
      }

      stdout.write(sembunyikanKursor); 
      tampilkanGrid(); 
      indeksSaatIni++;

      await Future.delayed(Duration(milliseconds: 5)); // Tetap menggunakan jeda waktu yang sama

      if (indeksSaatIni >= totalKarakterGrid) {
        indeksWarnaSaatIni++;
        indeksSaatIni = 0;
      }
    }

    stdout.write(tampilkanKursor); // Tampilkan kembali kursor setelah animasi selesai
  }

  // Mulai animasi saat program berjalan
  mulaiAnimasi();
}
