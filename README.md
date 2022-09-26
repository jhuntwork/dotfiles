# dotfiles
My personal configuration files

The most interesting thing about these files is the ssj function in [functions.sh](functions.sh).
I wanted a way to synchronize all my dotfiles seamlessly and without a major performance hit, to any machine that
I logged in to. Ideally, such a method would:

 * Not require any specific tools or settings on the remote machine, e.g., git or access to public internet.
 * Bypass anything that the OS might want to set for my shell or environment. I prefer to control explicitly what
 my environment looks like. (Note: this likely disables some expected functionality).
 * Happen on any remote login I want as part of the login process.
 * Not create a significant delay to the login time. Preferrably, it would even be unnoticeable.
