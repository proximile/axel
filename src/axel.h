/*
  Axel -- A lighter download accelerator for Linux and other Unices

  Copyright 2001-2007 Wilmer van der Gaast
  Copyright 2008      Y Giridhar Appaji Nag
  Copyright 2008-2009 Philipp Hagemeister
  Copyright 2015-2017 Joao Eriberto Mota Filho
  Copyright 2016      Stephen Thirlwall
  Copyright 2017      Antonio Quartulli
  Copyright 2017-2019 Ismael Luceno

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.

  In addition, as a special exception, the copyright holders give
  permission to link the code of portions of this program with the
  OpenSSL library under certain conditions as described in each
  individual source file, and distribute linked combinations including
  the two.

  You must obey the GNU General Public License in all respects for all
  of the code used other than OpenSSL. If you modify file(s) with this
  exception, you may extend this exception to your version of the
  file(s), but you are not obligated to do so. If you do not wish to do
  so, delete this exception statement from your version. If you delete
  this exception statement from all source files in the program, then
  also delete it here.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/* Main include file */

#ifndef AXEL_AXEL_H
#define AXEL_AXEL_H

#include <time.h>
#include <ctype.h>
#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#ifndef	NOGETOPTLONG
#include <getopt.h>
#endif
#include <limits.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <stdarg.h>
#include <stdbool.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <netinet/in_systm.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <pthread.h>
#include "compat-android.h"
#include "compat-bsd.h"
#include "compat-ssl.h"

/* GCC function attributes */
#ifdef HAVE_FUNC_ATTRIBUTE_FORMAT
#define PRINTF_FUNC(argn) __attribute__((format(__printf__, argn, argn+1)))
#else
#define PRINTF_FUNC(argn)
#endif

/* Internationalization */
#ifdef ENABLE_NLS
#define _(x)			gettext(x)
#include <libintl.h>
#include <locale.h>
#else
#define _(x)			(x)
#endif

/* Compiled-in settings */
/* Upper bound on URLs and the strings derived from them (host, path, file
 * name, redirect targets, request lines, ...). Long signed cloud-storage
 * URLs (S3/GCS/Azure presigned links, OAuth-token query strings) routinely
 * exceed 1 KiB, so this is sized generously. It is a fixed cap rather than
 * a dynamic allocation: the on-disk state (.st) file never stores the URL,
 * so growing this does not affect resumption of in-progress downloads. */
#define MAX_STRING		((size_t)32768)
#define MAX_ADD_HEADERS	10
#define MAX_REDIRECT		20
#define DEFAULT_IO_TIMEOUT	120
#define DEFAULT_USER_AGENT	"Axel/" VERSION " (" ARCH ")"

typedef struct {
	void *next;
	char text[MAX_STRING];
} message_t;

typedef message_t url_t;
typedef message_t axel_if_t;

/*
 * Worker threads place several MAX_STRING-sized buffers -- and, in the
 * speed-test path, a whole conn_t -- on their stacks. With MAX_STRING
 * large, those frames can exceed the small default thread-stack size of
 * some C libraries (notably musl's 128 KiB), so request an ample stack
 * explicitly. Falls back to the default stack if the attribute setup fails.
 */
static inline int
axel_pthread_create(pthread_t *thread, void *(*start)(void *), void *arg)
{
	pthread_attr_t attr;
	int ret;

	if (pthread_attr_init(&attr) != 0)
		return pthread_create(thread, NULL, start, arg);

	pthread_attr_setstacksize(&attr, (size_t)2 << 20);	/* 2 MiB */
	ret = pthread_create(thread, &attr, start, arg);
	pthread_attr_destroy(&attr);
	return ret;
}

#include "abuf.h"
#include "conf.h"
#include "tcp.h"
#include "ftp.h"
#include "http.h"
#include "conn.h"
#include "ssl.h"
#include "search.h"

#define min(a, b) \
	({ \
		__typeof__(a) __a = (a);	\
		__typeof__(b) __b = (b);	\
		__a < __b ? __a : __b;		\
	})
#define max(a, b) \
	({ \
		__typeof__(a) __a = (a);	\
		__typeof__(b) __b = (b);	\
		__a > __b ? __a : __b;		\
	})

typedef struct {
	conn_t *conn;
	conf_t *conf;
	char filename[MAX_STRING];
	double start_time;
	int next_state, finish_time;
	off_t bytes_done, start_byte, size;
	long long int bytes_per_second;
	struct timespec delay_time;
	int outfd;
	int ready;
	message_t *message, *last_message;
	url_t *url;
} axel_t;

axel_t *axel_new(conf_t *conf, int count, const search_t *urls);
int axel_open(axel_t *axel);
void axel_start(axel_t *axel);
void axel_do(axel_t *axel);
void axel_close(axel_t *axel);
void print_messages(axel_t *axel);

double axel_gettime(void);
ssize_t axel_rand64(uint64_t *);
int axel_rnd_init(void);

#define DN_MATCH_MALFORMED -1
int dn_match(const char *hostname, const char *pat, size_t pat_len);

char *axel_size_human(char *dst, size_t len, size_t value);

#endif				/* AXEL_AXEL_H */
