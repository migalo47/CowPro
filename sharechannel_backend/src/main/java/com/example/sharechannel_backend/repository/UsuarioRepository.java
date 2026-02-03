package com.example.sharechannel_backend.repository;

import com.example.sharechannel_backend.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Integer> {


    // Metodo para obtener un usuario por su correo electrónico (útil para el login)
    Optional<Usuario> findByCorreo(String correo);


}
