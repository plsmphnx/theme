/@if ($state == 'primary')/s/white/rgba(white, 0.8)/
/@if ($type == 'e')/s/$black/rgba($black, 0.4)/
/@if ($type == 'f')/s/$grey-950/rgba($grey-650, 0.25)/
/box-shadow: inset/s/3px/2px/g
/$_bsize/,+3s/3px/2px/g
/$trough_size:/s/3px/2px/g
/box-shadow: inset 0 1px/d
