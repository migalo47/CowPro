package com.example.sharechannel_backend.service;

import com.example.sharechannel_backend.model.Usuario;
import com.example.sharechannel_backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;
    @Autowired
    private PasswordEncoder passwordEncoder;

    public Usuario crearUsuario(Usuario usuario) {
        // Cifra la contraseña ANTES de guardar
        String contraseñaCifrada = passwordEncoder.encode(usuario.getContrasena());
        usuario.setContrasena(contraseñaCifrada);

        return usuarioRepository.save(usuario);
    }


    // Actualizar los datos de un usuario
    public Usuario actualizarUsuario(Usuario usuario) {
        Optional<Usuario> usuarioExistenteOpt = usuarioRepository.findById(usuario.getIdUsuario());
        if (usuarioExistenteOpt.isPresent()) {
            Usuario existente = usuarioExistenteOpt.get();

            // Solo actualiza si el campo no es null
            if (usuario.getNombre() != null) {
                existente.setNombre(usuario.getNombre());
            }
            if (usuario.getCorreo() != null) {
                existente.setCorreo(usuario.getCorreo());
            }
            if (usuario.getTelefono() != null) {
                existente.setTelefono(usuario.getTelefono());
            }
            if (usuario.getTipoUsuario() != null) {
                existente.setTipoUsuario(usuario.getTipoUsuario());
            }
            if (usuario.getHuellaDactilar() != null) {
                existente.setHuellaDactilar(usuario.getHuellaDactilar());
            }
            if (usuario.getContrasena() != null && !usuario.getContrasena().isBlank()) {
                String cifrada = passwordEncoder.encode(usuario.getContrasena());
                existente.setContrasena(cifrada);
            }

            return usuarioRepository.save(existente);
        }
        return null;
    }


    // Obtener un usuario por ID
    public Optional<Usuario> getUsuarioPorId(Integer usuarioId) {
        return usuarioRepository.findById(usuarioId);
    }

     //Obtener un usuario por email (útil para login)
    public Optional<Usuario> getUsuarioPorCorreo(String correo) {
        return usuarioRepository.findByCorreo(correo);
    }




    // Eliminar un usuario
    public void eliminarUsuario(Integer usuarioId) {
        usuarioRepository.deleteById(usuarioId);
    }

    public List<Usuario> getAllUsuarios() {
        return usuarioRepository.findAll();
    }

}

