" Mapping to create a new Property name constant
"    - The constants will be dropped at mark `a
"      The mark *must* exist beforehand!
"    - The macro will create a temporary mark `t to return to the original
"      position
"    - The cursor must be positioned on the line that defines the private
"      variable holding the property.
nnoremap <F6> 0WWWyemt`aoI	 public static final String PROP_pbgUEA = "pA";`t

" Mapping to write the code to fire the property changed event.
" Cursor must be positioned on the return type of the setter.
" Example usage:
"    - Search for "/void set"
"    - press F7
"    - press n
"    - repeat "F7", "n" as necessary
nnoremap <F7> w"syeww"tyew"nyeo "tpA "npbioldlgUlA = Athis."npA;jopropertyChangeSupport.firePropertyChange(PROP_"npbgUeA, old"npblllgUlA, "npA);
