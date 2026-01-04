# Instructions

1. Generate github keys

   ```
   cd ~/.ssh
   ssh-keygen -f github -N ""
   ssh-keygen -f github-signing -N ""
   ```

2. Add github.pub to your github account as an authentication key
3. Add github-signing.pub to your github account as a signing key
4. Checkoout this repo

   ```
   mkdir ~/code
   cd ~/code
   git clone git@github.com:scottwis/dotfiles.git
   ```

5. Edit ~/code/dotfiles/home/scott/.ssh/config

   You probably want to remove the entry for arm. That's my host, and you won't be able to ssh into it.

6. Close your web browser (it's probably firefox, and we are going to install a different version of it).

7. Run install.sh

   ```
   cd ~/code/dotfiles
   ./install.sh
   ```

8. Reboot

   ```
   sudo rebot now
   ```
   
   





