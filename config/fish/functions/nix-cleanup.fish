function nix-cleanup --description="Clean up the Nix store by removing unused packages"
    echo "Collecting garbage from the Nix store..."
    sudo nix-collect-garbage -d
    echo "Garbage collection complete!"
end
