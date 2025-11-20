<?php
namespace App\Controllers;

use App\Models\MemberTokenModel;

class LogoutController extends BaseController
{
    public function logout()
    {
        $modelToken = new MemberTokenModel();

        // Ambil token dari header Authorization
        $header = $this->request->getHeaderLine('Authorization');

        if (!$header || !str_starts_with($header, 'Bearer ')) {
            return $this->failResponse("Token tidak ditemukan", 401);
        }

        // Ambil token asli
        $token = trim(substr($header, 7));

        // Cari token berdasarkan auth_key
        $tokenRow = $modelToken->where('auth_key', $token)->first();

        if (!$tokenRow) {
            return $this->failResponse("Token tidak valid", 401);
        }

        // Hapus berdasarkan auth_key
        $modelToken->where('auth_key', $token)->delete();

        return $this->successResponse("Logout berhasil", []);
    }
}
