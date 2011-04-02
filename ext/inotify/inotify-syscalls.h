#ifndef _LINUX_INOTIFY_SYSCALLS_H
#define _LINUX_INOTIFY_SYSCALLS_H

#if defined(__i386__)
# define __NR_inotify_init	291
# define __NR_inotify_add_watch	292
# define __NR_inotify_rm_watch	293
#elif defined(__x86_64__)
# define __NR_inotify_init	253
# define __NR_inotify_add_watch	254
# define __NR_inotify_rm_watch	255
#elif defined(__ppc__)
# define __NR_inotify_init	275
# define __NR_inotify_add_watch	276
# define __NR_inotify_rm_watch	277
#elif defined (__ia64__)
# define __NR_inotify_init	1277
# define __NR_inotify_add_watch	1278
# define __NR_inotify_rm_watch	1279
#else
# error "Unsupported architecture!"
#endif

#endif /* _LINUX_INOTIFY_SYSCALLS_H */
