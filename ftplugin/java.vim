" The following two macros help with the repetitive code of property change
" support in Java Beans.
"
" Macro #1 creates the static constants containing the property names.
" Macro #2 creates the old/new values in the property setter and fires the
"          property change event.
"
" Simply drop this file into "~/.vim/ftplugin" to get it working.
"
" NOTE: The macros are not yet well tested. Use at your own risk.
" KNOWN ISSUE: If a property contains a type parameter (for example in
"              relations), the event-firing code will not be generated
"              correctly. But that is easily fixed by hand later on.

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

" Automatically insert an appropriate logger for the current class.
" Simply position the cursor somewhere *inside* the class and press F8.
"
" NOTE: This does a backwards search for the word "class". If that is not the
" class definition, this will do some unexpected magic!
nnoremap <F8> ?class<CR>wye<C-o>oprivate static final Logger LOG = Logger.getLogger(<CR><ESC>pA.class.getCanonicalName());<ESC>?^import<CR>oimport java.util.logging.Logger;<ESC>V{j:sort<CR><C-o><C-o>:noh<CR>==

set foldmethod=syntax
