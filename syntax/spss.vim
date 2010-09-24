" Vim syntax file
" Language:	SPSS command files (.sps)
" Author:	Kent Nassen (knassen@umich.edu)
" Maintainer:	Michel Albert <michel@albert.lu>
" Lastchange:	2010 Jun 2

" Remove any old syntax stuff hanging around
syntax clear
syntax case ignore

" TO DO:
"  - add matrix functions
"  - add the 'set' & 'show' commands
"  - disentangle the overlaps b/t keyword groups
"  - there are way too many keywords in the subcommands group; split it up?

" Note: I only had a SPSS v3 manual so there are probably a few missing keywords.

" Main SPSS Commands
syntax keyword spsKeyword add aggregate alscal anova autorecode begin bmdp break by cas case clear
       \ cluster compress compressed compute corr correlations count crosstabs
       \ data define descriptives discriminant display do document documents drop
       \ edit eject else end examine execute export factor file files finish flip
       \ formats freq frequencies get graph handle help hiloglinear if import
       \ info input into keep keyed label labels leave list logistic loglinear
       \ loop manova map match matrix mconvert means missing mult nlr nonpar npar
       \ numeric oneway osiris output partical plot point print probit procedure
       \ program proximities quick rank recode record regression reliability
       \ rename repeat repeating report reread response restore sample sas save
       \ scss select set show sort space split string subtitle survival t-test
       \ temporary tests title to transformations translate type update
       \ value values var variable variables vars vector weight width write xsave

" SPSS Subcommands (most of them, anyway :)
syntax keyword spsSubcommands $casenum adevice adjpred aempirical afreq after against
syntax keyword spsSubcommands aic ainds align all alpha alphanumeric analysis andrew
syntax keyword spsSubcommands append approximate ar area aresid ascal association
syntax keyword spsSubcommands asymmetric automatic avalue averf avonly backward
syntax keyword spsSubcommands badcorr balanced bar barchart bart bartlett baverage
syntax keyword spsSubcommands bcon bcov beuclid bias binary binfer binomial blank
syntax keyword spsSubcommands block blom blwmn bonfer bootstrap both boundary bounds
syntax keyword spsSubcommands box boxm boxplot boxplots break brief brkspace bseuclid
syntax keyword spsSubcommands bshape bstep btau by calculate canada case casefile
syntax keyword spsSubcommands cases categorical cc cells center centroid cha chalign
syntax keyword spsSubcommands chdspace chebychev chisq cholesky choropleth ci cin
syntax keyword spsSubcommands cinterval ckder class classify classplot cluster
syntax keyword spsSubcommands cnlr cochran code coeff colconf collin collinearity
syntax keyword spsSubcommands colspace column columnwise combined comm comma compare
syntax keyword spsSubcommands complete compositional compressed condense condition
syntax keyword spsSubcommands conditional config constrain content continued contour
syntax keyword spsSubcommands contrast converge cook cor corr correlation cosine
syntax keyword spsSubcommands count cov covariates covratio criteria crossbreak
syntax keyword spsSubcommands crshtol ctau cutoff cutpoint cweight d data db2 db3
syntax keyword spsSubcommands db4 dbf decomp default delta dendrogram density
syntax keyword spsSubcommands dependent derivatives descending descriptives design
syntax keyword spsSubcommands det deviation dfbeta dfe dffit dfreq diagonal dice
syntax keyword spsSubcommands dictionary difference digits dimenr dimens direct
syntax keyword spsSubcommands directions disper distance document documents dollar
syntax keyword spsSubcommands double draw dresid drop duncan duplicate durbin dvalue
syntax keyword spsSubcommands econverge effects efsize eigen empirical end enter
syntax keyword spsSubcommands eps equal equamax error errors estim estimation eta
syntax keyword spsSubcommands euclid europe every exact exclude execute expected
syntax keyword spsSubcommands experimental external extraction extreme fac facilities
syntax keyword spsSubcommands factors fieldnames file fin first fits fixed footnote
syntax keyword spsSubcommands format forward fout fpair fprecision fraction free
syntax keyword spsSubcommands freq frequencies friedman from fscore fstep ftolerance
syntax keyword spsSubcommands ftspace full functions gamma gcmdfile gcov gdata
syntax keyword spsSubcommands gdevice gemscal gg gls gmemory gout gresid group
syntax keyword spsSubcommands grouped guttman hamann hampel harmonic haverage
syntax keyword spsSubcommands hazard hbar header helmert hf hicicle hierarchical
syntax keyword spsSubcommands high highest histogram history homogeneity horizontal
syntax keyword spsSubcommands hotelling hsize huber hypoth icin id image in include
syntax keyword spsSubcommands increment index indicator individual indscal initial
syntax keyword spsSubcommands input intermed interval into inv istep iter iterate
syntax keyword spsSubcommands jaccard joint k-s k-w k1 k2 kaiser kappa keep kendall
syntax keyword spsSubcommands key kmo kurtosis labels lambda large last lastres lcon
syntax keyword spsSubcommands left level lever lftolerance limit line linearity
syntax keyword spsSubcommands list listwise local logit logsurv loss low lower
syntax keyword spsSubcommands lowest lr lrecl lsd m-w macros mahal manual map
syntax keyword spsSubcommands margins masterfile mat matrix max maximum maxminf
syntax keyword spsSubcommands maxorder maxorders maxsteps mca mcin mcnemar mdgroup
syntax keyword spsSubcommands mean means meansub meansubstitution median menu
syntax keyword spsSubcommands mestimator method min mineigen minimum minkowski
syntax keyword spsSubcommands minorientation minresid missing mixed ml mode model
syntax keyword spsSubcommands modeltype modlsd moses mrgroup mse multiple multipunch
syntax keyword spsSubcommands multiv multivariate muplus mwithin n_matrix n_scalar
syntax keyword spsSubcommands n_vector name names natres negative negsum nested
syntax keyword spsSubcommands newnames newpage nobalanced nobox nocatlabs nodiagonal
syntax keyword spsSubcommands noindex noinitial nokaiser nolabels nolables nolastres
syntax keyword spsSubcommands nominal none nonmissing nonormal noorigin normal
syntax keyword spsSubcommands normprob norotate nosig nostep notable noulb noupdate
syntax keyword spsSubcommands novalllabs nowarn npplot ntiles ntolerance numbered
syntax keyword spsSubcommands numeric oblimin observations occurs ochiai offset
syntax keyword spsSubcommands omeans onepage onetail oneway optimal optolerance
syntax keyword spsSubcommands ordered ordinal origin ortho outfile outlier outliers
syntax keyword spsSubcommands outs overall overlay overview paf page pairwise parall
syntax keyword spsSubcommands parallel partialplot partition pattern pc pcon percent
syntax keyword spsSubcommands percentiles ph2 phi pie pillai pin plain plot plotwise
syntax keyword spsSubcommands pmeans poisson polynomial pooled pout power pref
syntax keyword spsSubcommands presorted previous print priors prism probs procedures
syntax keyword spsSubcommands program proportion province prox pwer pyramid qr
syntax keyword spsSubcommands quartiles quartimax quick radial range ranges rankit
syntax keyword spsSubcommands rao ratio raw rcon rconverge records rectangular
syntax keyword spsSubcommands redundancy reference reg region regwgt remove rename
syntax keyword spsSubcommands repeated replace report repr resid residual residuals
syntax keyword spsSubcommands return rfraction right risk rotate rotation round
syntax keyword spsSubcommands row rowconf rows rowtype_ roy rr rt runs rw sample
syntax keyword spsSubcommands saslib savage save scale scan scatterplot schedule
syntax keyword spsSubcommands scheffe scores scratch sdbeta sdfit sdresid sekurt
syntax keyword spsSubcommands select selection semean separate sepred sequential
syntax keyword spsSubcommands serial ses seskew seuclid shape sheffe sig sign signif
syntax keyword spsSubcommands significance similar simple since single singledf
syntax keyword spsSubcommands size skewness skip slk sm small snk solution sort
syntax keyword spsSubcommands sorted spearman special split spread spreadlevel sr1
syntax keyword spsSubcommands sresid ss1 ss2 ss3 ss4 ss5 sscon sscp sstype stacked
syntax keyword spsSubcommands standardize starts statistics stemleaf step stepdown
syntax keyword spsSubcommands steplimit stepwise stimwght stressmin strictparallel
syntax keyword spsSubcommands string structure subjwght subtitle sum summary sumspace
syntax keyword spsSubcommands survival symbols symmetric tables tape tcov test ties
syntax keyword spsSubcommands tiestore title to tol tolerance total tree tspace tukey
syntax keyword spsSubcommands tukeyb twotail type uc uls unclassified uncompressed
syntax keyword spsSubcommands unconditinoal unconditional underscore uniform unique
syntax keyword spsSubcommands univ univariate univf unnumbered unselected untie upper
syntax keyword spsSubcommands uscounty usstates variable variables variance varimax
syntax keyword spsSubcommands vector vertical vicicle vs vsize vw w-w wald ward warn
syntax keyword spsSubcommands waverage width wilcoxon wild wilks with within wk1 wks
syntax keyword spsSubcommands workfile world wr wrap write wrk wsdesign xprod xtx
syntax keyword spsSubcommands zcorr zpp zpred zresid

" SPSS Functions
syntax keyword spsFunctions abs any arsin artan cdfnorm cfvar concat cos ctime.days ctime.hours
syntax keyword spsFunctions ctime.minutes data.wkyr data.yrday date.dmy date.mdy date.moyr date.qyr
syntax keyword spsFunctions exp index lag length lg10 ln lower lpad ltrim max mean min missing mod
syntax keyword spsFunctions nmiss normal number nvalid probit range rindex rnd rpad rtrim sd sin
syntax keyword spsFunctions sqrt string substr sum sysmis time.days time.hms trunc uniform upcase
syntax keyword spsFunctions value variance xdate.date xdate.hour xdate.jday xdate.mday xdate.minute
syntax keyword spsFunctions xdate.month xdate.quarter xdate.second xdate.tday xdate.time xdate.week
syntax keyword spsFunctions xdate.wkday xdate.year yrmoda

" SPSS system variables
syntax keyword spsSysVars $casenum $date $jdate $length $sysmis $time $width

" Comments and Strings
syntax region spsComment          start="/\*"  end="\*\/" contains=NONE
syntax region spsComment2         start="^\s\{-}\*"  end="\.$"  contains=NONE
syntax match  spsCommentError     "\*/"
syntax region  spsString            start=+'+  skip=+\\\\\|\\"+  end=+'+
syntax region  spsString2           start=+"+  skip=+\\\\\|\\'+  end=+"+

syntax keyword spsSysmis	sysmis copy
syntax keyword spsLogic		eq ne gt ge lt le yes no not and or inap missing lo lowest hi highest thru
syntax keyword spsFiles		file handle outfile lrecl records name write import export update
syntax match spsNofCases	/n of cases/ contains=NONE oneline
syntax match spsLogic2		"=\<\>\="
syntax match spsNumber /[=.-]\?\<[0-9]\+/
syn match spsIdentifier /\<[a-z][a-z0-9_]*\>/

hi link spsComment Comment
hi link spsComment2 Comment
hi link spsError Error
hi link spsFiles Character
hi link spsKeyword Statement
hi link spsLogic String
hi link spsNofCases Statement
hi link spsNumber Number
hi link spsSubcommands Statement
hi link spsString String
hi link spsString2 String
hi link spsIdentifier Identifier

