CPUS_L10X=STM8L10X
CPUS_L15X=STM8L05X_LD_VL STM8L15X_LD \
	STM8L15X_MD STM8L15X_MDP STM8AL31_L_MD STM8L05X_MD_VL \
	STM8L15X_HD STM8L05X_HD_VL
CPUS_S=STM8AF52Ax STM8AF622x STM8AF626x STM8AF62Ax \
	STM8S001 STM8S003 STM8S005 STM8S007 STM8S103 STM8S105 \
	STM8S207 STM8S208 STM8S903
CPUS_TL5X=STM8TL5X


.PHONY: all diff l10 l15 s tl5

#
# compilation targets
#

# compile all libraries for all CPUs
all: l10 l15 s tl5

# compile all libraries for STM8L10x CPUs
l10:
	rm -rf STM8L10*
	./patch-l10x.sh
	for i in $(CPUS_L10X); do ./compile-l10x.sh $$i; done

# compile all libraries for STM8L15x CPUs
l15:
	rm -rf STM8L15*
	./patch-l15x.sh
	for i in $(CPUS_L15X); do ./compile-l15x.sh $$i; done

# compile all libraries for STM8S CPUs
s:
	rm -rf STM8S*
	./patch-s.sh
	for i in $(CPUS_S); do ./compile-s.sh $$i; done

# compile all libraries for STM8TL5x CPUs
tl5:
	rm -rf STM8TL5*
	./patch-tl5x.sh
	for i in $(CPUS_TL5X); do ./compile-tl5x.sh $$i; done

#
# little helper functions/targets
#

# print a diff for directories a/ and b/ (to generate a patch file)
diff:
	-diff -rux "*~" a b || echo > /dev/null
