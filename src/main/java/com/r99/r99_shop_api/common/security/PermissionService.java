package com.r99.r99_shop_api.common.security;

import com.r99.r99_shop_api.module.auth.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service("perm")
@RequiredArgsConstructor
public class PermissionService {

    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public boolean can(String module, String action) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) return false;
        return userRepository.findByPhone(auth.getName())
                .map(user -> user.getRoles().stream()
                        .flatMap(role -> role.getPermissions().stream())
                        .anyMatch(p -> module.equals(p.getModule()) && action.equals(p.getAction())))
                .orElse(false);
    }
}
