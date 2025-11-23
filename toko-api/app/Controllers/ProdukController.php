<?php
namespace App\Controllers;
use App\Models\ProdukModel; // Import model produk

class ProdukController extends BaseController
{
    // Properti untuk menyimpan instance model
    protected $model;

    /**
     * Constructor
     * Fungsi ini otomatis dijalankan setiap kali ProdukController dipanggil.
     * Kita gunakan untuk inisialisasi model.
     */
    public function __construct()
    {
        $this->model = new ProdukModel();
    }

    /**
     * GET /produk
     * Mengambil semua data produk
     */
    public function list()
    {
        // $this->model->findAll() adalah perintah CI4 Model untuk: "SELECT * FROM produk"
        $data = $this->model->findAll();
        return $this->successResponse("Data produk ditemukan", $data);
    }

    /**
     * GET /produk/{id}
     * Mengambil detail satu produk berdasarkan ID
     * @param int $id - ID produk dari URL
     */
    public function detail($id = null)
    {
        // $this->model->find($id) adalah perintah CI4 Model untuk: "SELECT * FROM produk WHERE id = $id"
        $data = $this->model->find($id);
        if (!$data) {
            // Jika data kosong (produk tidak ditemukan)
            return $this->failResponse("Produk tidak ditemukan", 404);
        }
        return $this->successResponse("Detail produk", $data);
    }

    /**
     * POST /produk
     * Membuat data produk baru
     */
    public function create()
    {
        $data = $this->request->getJSON();

        // Validasi sederhana
        if (!isset($data->kode_produk) || !isset($data->nama_produk) || !isset($data->harga)) {
            return $this->failResponse("Data tidak lengkap", 400);
        }

        try {
            // $this->model->insert() akan mengembalikan ID baru jika sukses
            $newId = $this->model->insert((array) $data);

            // Ambil data lengkap yang baru saja dibuat
            $newData = $this->model->find($newId); 

            // Kirim data baru tersebut sebagai respons
            return $this->successResponse("Produk berhasil dibuat", $newData, 201);

        } catch (\Exception $e) {
            // Penanganan error duplikasi (jika kode_produk sudah ada)
            if(strpos($e->getMessage(), 'Duplicate entry') !== false) {
                return $this->failResponse("Kode produk sudah digunakan", 400);
            }
            // Error lainnya
            return $this->failResponse("Gagal membuat produk: " . $e->getMessage(), 500);
        }
    }

    /**
     * PUT /produk/{id}
     * Memperbarui data produk yang ada
     * @param int $id - ID produk dari URL
     */
    public function update($id = null)
    {
        $data = $this->request->getJSON();

        // Cek apakah produk yang akan di-update ada
        $existing = $this->model->find($id);
        if (!$existing) {
            return $this->failResponse("Produk tidak ditemukan", 404);
        }

        try {
            // $this->model->update($id, ...) adalah perintah: "UPDATE produk SET ... WHERE id = $id"
            $this->model->update($id, (array) $data);

            // Ambil data setelah di-update
            $updatedData = $this->model->find($id); 
            return $this->successResponse("Produk berhasil diperbarui", $updatedData);

        } catch (\Exception $e) {
            return $this->failResponse("Gagal memperbarui: " . $e->getMessage(), 500);
        }
    }

    /**
     * DELETE /produk/{id}
     * Menghapus data produk
     * @param int $id - ID produk dari URL
     */
    public function delete($id = null)
    {
        // Cek apakah produk yang akan dihapus ada
        $existing = $this->model->find($id);
        if (!$existing) {
            return $this->failResponse("Produk tidak ditemukan", 404);
        }

        try {
            // $this->model->delete($id) adalah perintah: "DELETE FROM produk WHERE id = $id"
            $this->model->delete($id);
            return $this->successResponse("Produk berhasil dihapus");
        } catch (\Exception $e) {
            return $this->failResponse("Gagal menghapus: " . $e->getMessage(), 500);
        }
    }
}