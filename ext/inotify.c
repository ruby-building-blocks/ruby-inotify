#include <ruby.h>
#include <rubyio.h>

#ifdef HAVE_LINUX_INOTIFY_H
#include <asm/unistd.h>
#include <linux/inotify.h>
#else
#include "inotify.h"
#include "inotify-syscalls.h"
#endif

VALUE rb_cInotify;

/*
 * call-seq: 
 *    Inotify.new => inotify
 *
 */

static VALUE rb_inotify_new(VALUE klass) {
	int fd;
	VALUE fnum;
	fd = inotify_init();
	fnum = INT2FIX(fd);
	return rb_class_new_instance(1, &fnum, klass);
}

void Init_inotify () {
	rb_cInotify = rb_define_class("Inotify", rb_cIO);
	rb_define_singleton_method(rb_cInotify, "new", rb_inotify_new, 0);
}
