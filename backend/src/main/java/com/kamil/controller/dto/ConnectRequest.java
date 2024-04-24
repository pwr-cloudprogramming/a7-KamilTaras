package com.kamil.controller.dto;

import com.kamil.model.Player;
import lombok.Data;

@Data
public class ConnectRequest {
    private Player player;
    private String gameId;
}
