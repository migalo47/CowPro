package com.example.sharechannel_backend.controller;

import com.example.sharechannel_backend.model.Usuario;
import com.example.sharechannel_backend.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/usuarios")

public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService;

    // Endpoint para crear un nuevo usuario
    @PostMapping
    public ResponseEntity<Usuario> crearUsuario(@RequestBody Usuario usuario) {
        Usuario nuevoUsuario = usuarioService.crearUsuario(usuario);
        return ResponseEntity.ok(nuevoUsuario);
    }

    // Endpoint para actualizar un usuario
    @PutMapping("/{id}")
    public ResponseEntity<Usuario> actualizarUsuario(@PathVariable Integer id, @RequestBody Usuario usuario) {
        usuario.setIdUsuario(id);
        Usuario usuarioActualizado = usuarioService.actualizarUsuario(usuario);
        if (usuarioActualizado != null) {
            return ResponseEntity.ok(usuarioActualizado);
        }
        return ResponseEntity.notFound().build(); // Si no se encuentra el usuario
    }
    // Endpoint para obtener un usuario por su ID
    @GetMapping("/{id}")
    public ResponseEntity<Usuario> getUsuarioPorId(@PathVariable Integer id) {
        Optional<Usuario> usuario = usuarioService.getUsuarioPorId(id);
        return usuario.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Endpoint para obtener un usuario por su email
    @GetMapping("/correo/{correo}")
    public ResponseEntity<Usuario> getUsuarioPorCorreo(@PathVariable String correo) {
        Optional<Usuario> usuario = usuarioService.getUsuarioPorCorreo(correo);
        return usuario.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Endpoint para eliminar un usuario
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarUsuario(@PathVariable Integer id) {
        usuarioService.eliminarUsuario(id);
        return ResponseEntity.noContent().build();
    }

    // Obtener todos los usuarios
    @GetMapping
    public List<Usuario> listarTodos() {
        return usuarioService.getAllUsuarios(); // Asegúrate que este método exista en el servicio
    }

}

