#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <glob.h>

#include "config.h"
#include "log.h"

static char pal[MAX_PAL + 1][MAX_COL + 1];

struct buf {
    size_t size;
    size_t cap;
    char *str;
};

static void pal_write(const char *str) {
    glob_t buf;
    glob(PTS_GLOB, GLOB_NOSORT, NULL, &buf);

    for (size_t i = 0; i < buf.gl_pathc; i++) {
        FILE *f = fopen(buf.gl_pathv[i], "w");

        if (f) {
            fputs(str, f);
            fclose(f);
        }
    }

    globfree(&buf);
    fputs(str, stdout);
}

static void seq_add(struct buf *seq, const char *fmt,
                    const int off, const char *col) {
    int ret;

    ret = snprintf(NULL, 0, fmt, off, col) + 1;

    if (!seq->size || (seq->size + ret) >= seq->cap) {
        seq->cap *= 2;
        seq->str  = realloc(seq->str, seq->cap);

        if (!seq->str) {
            die("failed to allocate memory");
        }
    }

    ret = snprintf(seq->str + seq->size, ret, fmt, off, col);

    if (ret < 0) {
        die("failed to construct sequences");
    }

    seq->size += ret;
}

static void pal_morph(const int max_cols) {
    struct buf seq = {
        .cap = 18, /* most frequent size */
    };

    const char *fmt_spe = "\033]%d;#%s\033\\";
    const char *fmt_pal = "\033]4;%d;#%s\033\\";

    seq_add(&seq, "\033]%d;#%s\033\\", 708, pal[1]);
    seq_add(&seq, fmt_spe, 12, pal[2]);

    for (int i = 3; i < max_cols; i++) {
        seq_add(&seq, fmt_pal, i - 3, pal[i]);

        /* some terminals require that these sequences go
         * after colors 0-16. other terminals flicker if
         * these sequences are sent too late. send them
         * as soon as possible */
        switch (i - 3) {
            case 0:
                /* background */
                seq_add(&seq, fmt_spe, 11, pal[1]);
                break;

            case 15:
                /* foreground, cursor */
                seq_add(&seq, fmt_spe, 10, pal[0]);
                break;
        }
    }

    pal_write(seq.str);
    free(seq.str);
}

static void pal_read(void) {
    int c;
    int color = 0;
    int num = 0;

    while ((c = fgetc(stdin)) != EOF) {
        if ((c >= 'A' && c <= 'F') ||
            (c >= 'a' && c <= 'f') ||
            (c >= '0' && c <= '9')) {

            if (color > MAX_COL) {
                die("invalid input found on stdin");
            }

            pal[num][color]   = c;
            pal[num][MAX_COL] = 0;
            color++;

        } else if (c == '\n') {
            if (color < MAX_COL) {
                die("invalid input found on stdin");
            }

            color = 0;
            num++;

            if (num > MAX_PAL) {
                break;
            }

        } else if (c == '#') {
            continue;

        } else {
            die("invalid input found on stdin");
        }
    }

    pal_morph(num);
}

int main(int argc, char **argv) {
    int flag = 0;

    if (argc > 1 && *++argv[1]) {
        flag = argv[1][0];
    }

    switch (flag) {
        case 'v':
            msg("paleta 0.2.0");
            break;

        case 0: {
            pal_read();
            break;
        }

        default:
            msg("usage: paleta -[hv] <stdin>\n");
            break;
    }

    return 0;
}
