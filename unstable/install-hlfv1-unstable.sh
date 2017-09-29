ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� cB�Y �=�r�Hv��d3A�IJ��&��;cil� 	�����*Z"%�$K�W��$DM�B�Rq+��U���F�!���@^�� ��E�$zf�� ��ӧo�֍Ӈ*V���)����uث��1T��?yD"�����B�y"��HH��h����B�	����X64xb���Y��=��B�����"���,dv4Y;����L�6�d���v�O�C�뤬�k#SGj����1�b�mlږK x�-l;��V���fb��{��8��R���a>���� \?Q�h���M����UhC�2�aySB��W�2�<�	��!d�jK3��ab]�+!�D6��?,WJ��j�bc����n���h@�@��;���'�ٴy�Rl2iG&�i:Z<��7m����,��,��ڶ� �ވ�@�U�/,�`�*^kqb���^�����BC6��MO%��A�Zخ�Bء��x�T�IXn�ϟ�!-��i��f[�	<�~t	[m��D��0�)��3łQ(.[��5(ZP�e��IZ�Ь����"\e��2o��n��+Џ	���K�Dd��3�ϟ�9�������>:Ȳ+Ń�e�ԅ�#]��C��C���C��;wS(c"�G�o��G����.6�̮��ݳ��F���-��]�.�����W�T��Q�O�4��mP'/���(�?Q�B���İ���'3���f�������k_�V�m���_1��I��(Q�?*#k���@U3Uh58;�� �|(*��j&՘��u\.흗+�D��σ-|�=hwU�)p�cH��,_�.�5����O��ʿ\��*`-�_6̐�6T����6�v�'�=��BxJ�#k��"�����&3��؉/��-�>�Az����,`c@g�s�l@�d��A:n�C1�vZ6h;&ݙy��M�m�5�t+2y����O�'<u��6���В'�J7���g�6ƺ��9oS�C�n`s��)��p��k
2,ֶL���|A�,�&��:���czYձ�Tpxj�[Xw�Z�#�in#����^{�ξ5������JC�0\���m����X�].�"ߣђ�H�l�(�?��1��<����W��H�K�#8�Yx�Il�ɠ��gQ}��6���d]O��C�u��A�tR�Q���0��q� ��@�1�a>��MM�4T`�� R����f�G/�,nXɲq{s���#q����X�-����i5��z�G"� ��<>��$�
�����'�Qڐ4{���?� a؀w.����(s5�4�l����z�r��m�5[��m�Og1=�@<>k�-�����Θ����h�i���y[�q�ޢk��cv	��=��ve~l� ;�i`\��e�)����Q��Oq6������Ѓ3�'1ǟ��ҧ�+R��ȅ���٬����Ǟ� ��pG��.�#h!`!)6�64�0�l����܏��&cN�=`��xo��zs����-�#�3�f�e����l�^�N�oTi����({��-&N���6_�!N�<Dt����
�k]j�W�,�p*6���0��SFz��
w?����������?_6̐��Z>PK�_���i��翫�OJ��a\��=[`g4��ӧ]=ꎙX�9��fLXu�4�4)�5������w?A�p�l鼔(f�ʻ?݄�j����������c���K�Y�]/7-ǋ���q�X��_^�Gn���N  ��a!�q�-�EpÆ�%�\�v��"��O�P�[��'��ҝ�����r�|^��R����^O����"��Z[7�0Q{W�c�~��v_����}x��E�~޽�g6��g��D��0ܒ0�rnWw@���N��L��}�5sK�H��9Y2��	�@�0a�>�T�w\�ق��\�9Fl��W���F����wkpg�/�������l��������e��i�/Z���^��g���=3�-�dAt�|mմK0��𰃞e_k�{�������2���?������\,_�ù�y������n���	
^v�#DCS�
E��%0��7Ew�� {pӲ2Ml�mS3l�h���st�Cj�M�u����1'{�?;���Z?/>%��1![j86{��h�|wIO���g٨h��=k�s"�Y��ӿޫ���X�M��˱�gҙ[!�.�����Աu$e#��>��<~�lx���Bl�	��=�<�1�a�!]�`����a�u��;g�����8]���,`�.Pt����[������/��Qi��'���Z�?>�_���H��
���ㅈذ��R��GgD�з�^�s�p Z{<��xz�q� ����2|�	[AF�.��wj;JC�NTY������,������`8�����/��[�#�b[Z�a��zob�)>���Ǐ
�/�U���������ȴ�K��:�w%p_�����]vCd�3}z?��v`� �|ƞ2:�F0��k5Iw��=�*��g( �@�[�v�I��,`44�mN�s7�
�m�#H�������vы��K3�-ef��k��e�`���l7Ɉ��K��N�1QG�_�Ʉ>K3qx	$fdؘJ43s�D���2f%Ƙ�0�cr�S�d�_��R��d��O��+e,���s��(�YW�<�"�G�ó�y7�ثCA_Px�onm��ڸ���J���U�����\��/��Ax��_!�>�	��u��J�����s��7_��o��?�������)���O(TI
ƶk���R֪5Iَ�"�j,(�I"�"R�I
�b�XL�F����v8��_s���&�!o�+�wr��k�!�����WԼm<��9�%�aa�֜��?o��1�`��o�뫍�|5I�߿����~�r�Y������n�|�G2d�����l^Mk�O	���q��F��x�������^y�.��ýSw��!a��W����t��ic���\)"���p�����ҭ�����Nc����$}���?h�M����7S�N��;׼���9[�m|�AE	ª���jMP��!a��C5E�n+1)B�'"�*��$(P܎�XU�B����&�!�k^AD�֨���Q��2�<H���l:���)V���e���E"!+������z�(�C�8����~�p�����iv�e�.���*W�BAnfd���7r����e�J.���cB��h�Ռު��8�$u���+�3��<&ϴx潡���iP�:n_f��[�S�X��*圽m4�o��Y)|Q
�{I�8�r*�o�7Z31�{%�++��E6�+g��r6xB�.X�0({o�\ī���MN�ǅB&�}s\�J�sd�����~!����YGi�ۧ��I.^pG~�˿7*���M��NO��m��z����Ð�ݓ�Iц'a�̅�+�u�I�J�R?h�;�r���d<���>fJ9)&�S�D���M��BV�g����xA�4/K��1>�D�o������I�y8)��������qT/Vj�p_�OC��i�\�,z��&��h�ʩG�ș��e����r9~��%���j������{����s�W����vJ���\¢�R��B3�ؗ��y�h<��7��A�����n	���CSH�#9-�&�G����x82��	Y�˹T%�-$$k�yo$R����)���U,|4����d6�J�I�{�$�@=[/��#���Sq��0���bQ���x{��;���KH�hG�W���{��|*��!|�������Q?Ќ�#�1��l��AtsC}A#B�	8x��L�@��ۋ�=���'����nM��Ǿ�����h��OH��������tT�� �S���)��f��M���xF�B�C
uA�v��XĴf5�;;������3'����I�\�F�i�+!�E���
�|���4��0}yu,�:~YE���tܬ�
�p/��Q�r��h�D�Ĩ`��(9��8���^Y@-�5p.�Z���ܳ�ˁ_���n������>��w��{�kx�˰��Y���s%0n�+�lb�����T�t�;�Hȅ�QHR.(�B]N�h�L��XN��]�ԝ�%�7�6<j��r�0}��5SHq�go��t1��X��mq��yevː��⁥u/��^ۨ��0)�ww��t�>���v��׶1,�iu��W��f�wXZ�\<	��,.2ϑof�d]EZf�"b|���g4��(��wঽ��g�5�;`����D�����H�f��$QM341�k4��;��@�N��xQK��*���]��i��%N�y<mȳ�� @��f쀱�*V��mS�|����%� }�@gT���,����%�~�ް��~�n[��A�<<#�{k.��m���<���Ge^F~Ĺ�၏;�F�b� [Gk7X��a&Yd���^D�4�A��]���L�ᬠ�ӣ�j�d|� Gp ��Bt��.4X.%RʈL��+W]
6lz �&��i!�mj�"�S���z�mK�]"�vb*tՓ�gS�f}t4�����~�����4,/�+]t���3l���y�TԷX_��r����hB��b�󘚊���Z7�'���.��]m���Č-���?|��'�\N����D�ܴUz���O�u��f���4�$5�!��W�DV�2Z�=�������^�ƤLk���� OJ����C_q��R��86A,�5l�G ]H�Y1X%83�T����S.	|<�B\;�݋�T "�6��JإH�B�-F�"���G�1ʀ����7�_���@�Sy��@O;��lw�b�z#���t3��2K6Y��W��n���e�6Tt	6K���G��P����U��l�Ql�>���o�'D0��du#�v�*C:14�t˱:!D�(�c)"�b06�T����y*��dM[����ꔶ;:���h".�htB��*�ݮ6��:�`]��tX��9�	�e�q3���M�}��#�!��%�����,]�~�`~~��ĩb���Eߛ���R�
���g8'��*��s�x,��zĆ;�@K6џ�[G�Ж�����6��E)$L�����k�uK��=Msq7=Ej�A����F}��#��\���c'qn���dq��N��y�؉�,P�@H3�H�b7#�!1�0,����b�!v�|�q�]�[�sZ}�^����:���� �߽$��`(�%��?���o�s�/�=�+�o~���b�o������/~����%��8�9�|G�o����Go�b������	U���0��dE¤pH�P�Z�P8ҔCxL�H
k��n�R!�2Nd[��9d�B�������������?�������tn� ��Ɓ�Ð�b�����>��
E�����w�����{��� ���G����P���a�ˇ�z����o��[��v���+ ��2p�b6��u��򱡥c)��{e�a�S��9��{�|���=f	�U�m�U.�
�Ӳw��nT������b����0�yvIB�>zR�5$���~V�!BJ�Ǘt�F��EZ��BQ09{h<g��zu>nb��@�
ź���g�5�p�8Lw���EdgB�o&L�ᔛ3��[�̠�Wq��,O�D������<,�ͳ�z�ܝ��H�@�T�a���~�/O�f gλhչi��y}���K#����X�5Š�t�ZL��Hw�Hdg%�ܜ)�b��2�])��ɂn�<]H�m�}'9�(D�����za��dM�Y�3�M@ϖ�B�
a��:I���#:�I7�s�|�4Ҥ���Y���������ÛE�hUY��N|1�Z�g0u��2�E5ry�f���3�u��֗��i'�'kZ�LRҬZ*E:9�ҳq�ss�?9�Ǌ�!����%tu6��.���Jn���+��+��+��+��+��+��+��+��+��+�����1�w�7K)��~�T��d��α�v�YMċ1��ĩl��i��p��v�{Q;+
�U99_"@��E� ࡐ��Z� @��N�D͔� t7o`������Z���S�!VLF��М!2�<2�H�*�[��6K�X5E��L�PK��9��U�
'�R�Q459��Mpb46GR�,PW���?7Q?�ƈn��X��X��Ζ��k�TN�{KoEd�2C�¹y���ЩY8�Ñ)��Q
>����L�5�z�Sd�HGq���Z&B�X-��
�̝VT��(�&�<"cmVj����`��%\�]�B��_�����G����8z������c�y����p�]��wC�3佸}.6���0?���"�I�����ܾ?� u���ԩ���w pd�����׼\T,�G���G��}��o ��\��|����O��0�����_)�2KK���J��Ft�u��3�E��k��nm�|I|�:?��%W�ǉM�o�	[���I������,X�ӕ\�m�f��Bl�U0��#�LcS���J��~&JU�E��r�Ϭ��0&�cB�QJ�%�HE�T�J�㼒���Wg�rl�gs�o�S�� �7��n��ユ���IӘ7´mW��A"�Q�q�2£&R�-e�P�C�,�]��Y�i2�:~�Y:���4�
qH2�)�L����r�24�Q�r;y�G"���[h�`�Ҩ[��zI�"k���M�,��*�֔E?_K6q�[*8&*�H�_�YD#�hA��f������icL/�m�2C�֔��l���tm�VB'>��_f<��+�&�g(�i��˃�0�d�h&�w���rK��_��/���̦��X��@fٮ����p�������Ȳ�EVY�x��=3+=.�;r[~w��6~��;ݳ�D�Yզ���T8��B.ӡeO6t�������3y����i��`�aI�f��~U-��Ju��a�)f�a�nm��|�F�x��6�4U��g���P�
-Цm(s��h�<�����&?�;��\ G�B>�w������Ǒj�����	�B0�s�҉'��.Y|���i��+�FEI��}�,��t)2K#L�͛�!p�y�(Z�a�p4�J����s��.L�+źx?��!��(�^���&��+y"+E�X)!;�Ú�
x���])$lY%f�ݯ"�I�Q$�k?j�m�`��	�	r�#W� +;�Re"Y�1W��9�*Ŀ�Z����P�\i����:����'O�ꀋM�$�sq�nW��Q(��[�c\��X��EI���YJ+�G�n2�-�ә�D��	�(�U(��Qv(�H9S�C�L�|�4%/�C��I��T�<�)ļ�N��R���
Ct3j)���p�,4�S��+U�!ҵZl��g$����J���Q˨Ę�y�J��)0��(,���am!6�j��c�w3yvihe��j�[���g��x�o�y��n�~���d�v!��%�c�ݘ��W������/#?Ns��>���X	<���������1�3�d��%u���}�<x��9����A/Ϸ�w`�v�x7�&�����)�u|èH�*�>$����$��J����ȃ�������Yu��G���	��p�dHN���9���;�_+}���#�šey�躢��#�C����=z]���Y9B^��;���[|�x"c~=�/LW|�èЖ��p?|��Gz9�_��>z�	�:�G���Y��V���5����N� ��T�|9ص2����#�A�ɰ*I���4P�.v�����Q o��f_����'0���ϑ�I�3��U?��vW@��wN��:oXU��e��ѥ�e�p?]��xo}�Y׋llݮ��V �W��bNvt�dG�^6��S�{{��:����dC�N���Ѹ�G�ڀ"��=,iA�1
@>ڈA�)��Yt?Q`��� �3����PїA������a���&����� �1^0�s�$䍠�M598T,��]N}*�~yj�Wsj�2 ��,>_�� �jd�0�!�l�x�xK|t���]�C�8s"�������W��Zom���A��h��p�NFC�Wf�:竍g���`�`}?iE�<�Uae�Wa�ɪ�
E��c,]gh�cm�kd�v���N�k��Б��1�>k�c�,�ۀ��ɸ�Ћ�'�� �a~�[�X�N�őU��	WDV���_�����	?3 WL�Xٜ�M�����u�y�����h�lH؏���V��u���ůK~������&x�d2�u��c�������Б��� �N�
��`iA�덺\��Yp���7��O�x0�27�j��'p��yC��G I	|�<���E>�]]�R�88sx�n�%��}<�%��h+[�0(i�+YE��֕��r��m)y��S���p���t;��
�Rɽ}Q�.�z&��}�*i��s�����/���;u��[ Y춽-���/�x�݅�A���4 (O(t�Ǡ����푋�*T
6AYX��,�$H�뵃�`g�����z`u���A΀$ xU9�cM�H�`��cf�\L���+��5����
7i��悐1ktӚ穥�A��°&ٞ+��v�M�x��6��/��W&��YÒW]\u��J�9MX-;ǢA���.�/p�e�{c���_�v[���6,�i�q�U_�V�N��n��4���*Y�]l5�`WB�D�ԙ�S�''���ɨԃ�aM�!]�<���8� ��YW����lN�N :��O`����X�Mܶ6�4ND�b p�I�+I῜�FnG����- 	l�);JC:@��[�������c3�M���X��_�p�P>=�U ��~ԁ��x׎�e-���\�}�����o;�͕m\q�����?�P;���#���	�	� P[�U�#�-+a0��kD�}��=����Y�>�1����BwV��䎂%�X��,mU����G���|���v���?g���+:��7kG"Yj�H�IHR���E"CJ�lST��Rڸi�D4C��1Bn���%��QE"(�L�ۂ�=���� f>sb�XVi7���d�?��|b=y
�
c�\{;ě0�ξ��Y�xLjR��l6�p�Ȓ�J��I1I�(*S"X��*!�)�RȚ�hL	G\�$Ś���������'�'p6f��6P|����޹%�'���Nx�3���.*�2���,�#��+���l�+�\Ѣ�$��t�,�Kf�
�y&+�i��l|I�4��R��+�����_81�c����+��f/����k�*Ng�R�g���Ǯ�"]mua��ݳ.x�� ��ڑ���t��3�j�>i���N�����j�i];l�}�¶I{�L��Z�v�c;7L���l��9CV�Hv��%�)��V���=�+r�ȓ|6y��������g�9v���	�c�����˲���M���EQp��It2:��S�O��$h�̢�KO��y]n�`6���f��\��*�ʕ�x.���gYN�抧�5�g.��/��7��:���v&�]{�S�<:�1�j86i�-����?YZ���=����,sI�x�O��3&�/w�܈�d,~���m��(x�ę=xg�Y[�t���	��A�.bj��N�i��|��f��Ķ��7����B?&��
|k���2���Շ��Gm�;�$�0r�c��v�].nv��ݱ��VD�C��Y������
���^�l�x7�o׋6y7��&��!��>���Gw�q��Y�;qX�}���[2�6�""�a���^	��$���;���Gz��ohzK�M��C�C����B�S����Kz�?�c�򟌄�i_������}O�W6�K�_��'7�������t�@s�@s�@�B=��7K�(���#�����Kڗ���1���,��#Q�dG��f;D�Yj�"Q��PQ,��Bd$Ԍ��J�<LH�3�eQ�W;�
���o���_{I>�o3L�����:4��H+���9r\��hJh8�A��P��+�ye�In�O%�
�9�.rM}is����C
�1��-.��hY����Tč����[��餔��&�Jq��R�J�)�����1��������_~z�������˗�66��yH��>��6��8u8��Gz�?��8���>Ҿ������W>��A�߿��:�##����G�g����=_�t������l������W@�ë� t8%�:�����w�OR��:��}�WK�C?��P��K�����?��%������>�!T�!T���we݉�]��_�޻V�<\�k}L*"(ܼ�I�	���Ī�hwR�
Е��RV*)E7��s�~����O��{0�	�����w���P�m�W����?��KB���C+@�
����!���U���?\����^βvc��r���v.���������?���'�3������}x����|l�3���'�J�|����m�Y8FO�].��R�ݳ�z�y���d����v�f*V���bK�*[�{����a����y�j�G��ǰ=���7Rs������'�#{�mw��2�u�|����]#N���	Ie��{��r6O����}��ݢ��{a�ʑ�GN���Fܳ�]#JI1|iZ��C$*��ʷ)�=�M{?���?�m�O��NU�Вc����l�n�A-���+C��ӂ(X � �����j�������H�*����?�p�w)��'���'������p�e��/�#��
P�m�W�~o���)��2P+��MP�"�P���uxs�ߺ������:��1����������X�q�������s]�R���xt�Ŀ/둷���A�N��<�����l(��h���p���R-�B{D�V���׌��ɞ"(Q��'��mgL���T�y)��͐�uMΞ�z�u}�k|�T���;����\�/�ȕ��K������7/?ph(s^%c�S��Jp�u\t�4�	�$�L�Km����f[Aۨ��|�:t~8sMRF�劉7j(9�����%#m�֧�a���Z�?���@����ex���.��@����_��x�^x����)��3c��>Jc�R�R(�q^����z�ﳾOЄK3>Nx>J��O�!
g�8��������/�2�?+z��8�B2h��:�dI�wwJ�<� �yg��&��k�/�����H�GO�F��ɪ}�&�md:�9���40��&��7��e;F��H�%����9L/mFT��6Ó���/�p�����P�����o������P�����P���\���_�/�:�?���W�ݐ��*7��q�D&rp�3�O9�^�v��Y8�§�0K��O�t_�Ѡ3�~��.��ݶK�92���œC��F�����*:�C�2���306dUɦ�9��E=��8�������������u������ �_���_����j�ЀU���a�����+o�?��迈���?��}[���0���ɱ|�����J��>����6�����Ϝ�<=�g  ֳ� �HU�=Z���RE�� �y og	9�U����B-��D��n����vs���,LS�����>�u��A�����I;�s�E����7�E��99�}7�^��5������3 �%�p�vB$����D��;��.�iF� ��Ǒ y,V�w�P(�H���>�f?�I[�41z�@0��&4��FX9%|�q&��pҀ�k�!*�HE��!m5���-|�1��!��3I�m���m�#2����k�fҷ�"A��:�:�x���l�k��K��ng|���0��#A���Ͽ��.Lx�e\�������P0�Q���8���������L�ڢ,�������_��?����������?a��_J��z4�z���,�n��!�.�.M�\Ƞ,͆���� \��I&�\�a���P�����/
��R�+���wXJjS��ܱp��=|4�œ���\ߎȂ�521��e��J�$����4r�%����m�=6�!�YB?���n�Gqyn����Fy�\	�<����f�8��D�tZ֮�����u��c����)���׈���%��P�����O��e��O���0�W��7Xǐ�^G ��W������t��_���k����G��	��2�f��������C3��)��Ʉ�y�2������o�wo��2�ϑ����>�����������w����p�)�q�Zp�7g��V=	�^�LK%�#�O�:^P{Z�#��:��r<bVC{6uU^m��ǔ�8�������i�`H;�|nG���,���d��r�����D�;ƹ���q�������ަk3���ߡb��b�KuH�=�OeG�&ۢb�d�4"��ֳ�!ɺG���|�4I�Bs3��w�f�D&���Z��ȩ++��1�����E�Hr�1��!_���P�wQ{p�oE(G����u��_[�Ձ�q���׊P.�� x�P�����7M@�_)��o����o����?����U@-����u���W�����Kp�Z���	��2 ��������[m����7
��|����]h���e\����$��������}�O ��������?���?����W����!*�?����=�� �_
j��Q!����+����/0�Q
���Q6���� !��@��?@�ÿz��P�����0�Qj��`3�B@����_-����� �/	5�X� u���?���P
 �� ������"�������j��������(����?���P
 �� ������?�,5�Y��U���k�Z���{��翗�Z�?����:��0�_`���a��_]��j�����Wj����9�'���
 ����u���{�(u���Aڛ�>�(;c�p��s$N�����E}�D}c��0�u9�$)��g��_ԁ�	���"����ѥ��*Oo��s�8��@�6��Wo�0"U�^OP����K�F�>?BMl���ju\���/�����!��<?��̰�a��ˢ�L��kq�4�0B���>C�L�V!e�:x;���xc'����!��|S��Ա�p
�<����ݓ����p�����P�����o������P�����P���\���_�/�:�?���W��ШSc߷�Vc��Ⱦћ�bg1�a��/[��?�q_�?+\�̓�ҋ&�oX�n7W�xu���d�"�!u�(<a���m�Ӄ���b>MOm~;�jҠO�i3�QBU�v��eJ��ｨ�����w�KB�������_��0��_���`���`�����?��@-����������xK����������MF�8w�Ɯ���
�Q������j������N�ic��|���d�i��-S�o6���Ҥٙ�^�v0	$o;��N�CS=b�^4��aF�U�z�Ş�ΈL��q/�S� �}��3���Ƚ�G/��5���҉���n	�&\�;!�[���/xysY���|�E�PoG��X��uC�XG
�"��O��L'm5�_�yM6D�Ü<{�I���c�d�1({�y!�S����Ák�{KG�cAN�p=7Q� Z������$J;��Ĳ9ۤ�5����
�$�'� ܽ���?��E����3�������?��/u��0�A�'������?%���WmQ���q�'Q��/u�����$�(���s=!ӣ~(���1��y���(N��W���tK���=�Cӏk#�Lb�a���.��u�rO���-�7o�"��Y���g�M���[�t�|����?Y~�G���Y~�w�������_[��&D7�rx�.���5��sl���-!�_�VE��j��_���0쑯�i#�W�@F���en'��e*�?���1L%��a����9s�7)a��tze��h�&V{8�[�w	����?�h�'+��}s��v��rYs!��ׯy��l?�雭�CF���O�@��X��M�-������f�܈��fǠ�?��Y��ֱ^�̑��%A�c��b����R�w:`T0��O&�i���©K�F�DBl7]!7OS�஽\���(PGnJ��l9�?�̾��˿��wC-�u7��ߒP��c<
�h�p=f�b$�r3�����$�s3��Q���|�$��K0�S>z憨����Y�C�?��0�W
~���DG3���� �V��N������]��ɣ�2�#�/���r��j��\����/>��5?���0��2P��1Ľ��������(��������4�R���+������S��oe�0�g]f�:��w��k����y�e�NΩ'��j�!��������������o�	�����|��퇼��3�xov��Z�@�t�!����0���pkL�Qśv�8�:�i^\{����|rH>cg�b�nu�XI����|����~�����b|3�y{�n�����v���t��-3��ye�,xy����$</���Ys{�a�Nr9�_J�������v�#��j^���!Ͱ�\؄sr6��7V]��+��l��
3_����u������-%��)��I?�YC���׎�O_���0�y�b.���o��.X��]�.�`,G����(�����G<}�A�}>~�����봍�Z�r;����8y��Ɖf;T����'Z�;������Z�����ދ���_~?��1
�_������{����+e|����/��XK ��W����UJ���h�e��?�л�����/o��k�����Gc�m*��6�C�'��~��������?ؚ���z��}l��v���[�H '�%�4=���K˳�J.�)ϏI��G�w�\!m]�:W��ѕ~������o�ܟ�Ķ=�;7'u���t󐇞:�U��`�~{�V  > E����B۝t�3�̤�L\�������k������J�w]�u%���uNj�G�3�u����;z*��]k4�t]�o���j�t��9>�V{f4�{�Y�b9m�U:�[r�劘��?ݶZ�jx���)4����c�������q��Y�R7V<�oMֳ�F�k���^[�?^l��4���Vْ�6/Ju�����Bhj��1)uLy62��x5������*&-%�h�Y�Z?�z��ʀ)�u�ZIuG��e��8���j��I�.����\��O������7��dB�����W���m�/��?�#K��@�����2��/B�w&@�'�B�'���?�o��?��@.�����<�?���#c��Bp9#��E��D�a�?�����oP�꿃����y�/�W	�Y|����3$��ِ��/�C�ό�F�/���G�	�������J�/��f*�O�Q_; ���^�i�"�����u!����\��+�P��Y������J����CB��l��P��?�.����+㿐��	(�?H
A���m��B��� �##�����\������� ������0��_��ԅ@���m��B�a�9����\�������L��P��?@����W�?��O&���Bǆ�Ā���_.���R��2!����ȅ���Ȁ�������%����"P�+�F^`�����o��˃����Ȉ\���e�z����Qfh���V�6���V�Ě&_2)�����Z��eL�L�E��؏�[ݺ?=y��"w��C�6���;=e��Ex�:}���`W��ؔ��V�7�r�,IO��j]��XK��]��N�;u�dE?�)�Z�ƶ�͗�
�dG{�ݔ=!��4]�ݢ�:肸�Bbfk�6C�VXK2�*C�	���b���q�cתG��<s�����]����h�+���g��P7x��C��?с����0��������<�?������?�>qQ�����?��5�I˻Z�C���Hb1�(�e��q˶�Ӷ���rgO���_�:Z���`�э����fCM�"vX"�h�.�j��oՋ�mXù��5vy���|�TǮ6�Wr`R��
=	��ג���㿈@��ڽ����"�_�������/����/����؀Ʌ��r�_���f��G�����k��(����i=�0r�������M����+bM�ɔ��į�@q��`�r�M Alz�q�%I�ݟE�ݢ��ƚ>��uwR�K"}&V<.l����ة����$�M�Aj=z�\ks��u�]�6A��6�zE�6�l����ӯ��ya�h������d�]��]��OE�;���{Ex��$%N�� ;��YU+�c���{i�a/l>%��j�S(�tj9�����lԚ{�Lkl�,��fS�
��A����*aJ�t,�a�u�]��,�=btywุmȤ֮4����m������X��������v�`��������?�J�Y���,ȅ��W�x��,�L��^���}z@�A�Q�?M^��,ς�gR�O��P7�����\��+�?0��	����"�����G��̕���̈́<�?T�̞���{�?����=P��?B���%�ue��L@n��
�H�����\�?������?,���\���e�/������S���}��P�Ҿ=�#���*ߛps˸�����q�������ib��rW���a&�#M��^��;i������s��������nщ���x�ju~�I�Z�����be�Ì��yyC��Rѧ���!;3��08A���rf����i�������(M���h��s�/v%�Wӫ��#
��CK.H��G��m�>+�Z�[�e�:	�zޯ�L��3�uj�n6#���YMڒ��IV'��f5�������>v+E,D�\0k�0ۻce�2��4�}"8*�bu;���`�������n�[��۶�r��0���<���KȔ\��W�Q0��	P��A�/�����g`����ϋ��n����۶�r��,	������=` �Ʌ�������_����/�?�۱ר/"a�ri���As2����k����c�~�h�MomlF��4�����~��Pڇ�Zy�����E��T4��xOUg=��o*ڴEo�:_�!�)��+Q��>{�fq� h�v������Ʋ��#�s �4	��� `i��� �b!�	�=n��r���"�+�r�0e�U����taQ�{��'�zWRD6,oZr��#�rXa�)��A,�6u�+�ք�b}���n�&�ue����	���O���n����۶���E�J��"��G��2�Z��,N3�rI3�ER�-��9F�Xڢi�T6YʰH�'-�5L���r����1|���g&�m�O��φ��瀟�}�qK��t��'l$���Ҩ��'�^[�V5s���GoB��]0�@����OD��W�5&�X%^�vQ�Z��\�N%�.,OÎ9�z����,�T-+��>v�e7�����%�?��D��?]
u�8y����CG.����\��L�@�Mq��A���CǏ����n=^,kzGVEbNbb�h��r����֢�S�c'�n��?�/��p��}߯0���ˬ	)�c�c�:b'dq��uz@̏-��+>�jFmY7��zDg��q�Ckrp��ג���"������ y�oh� 0Br��_Ȁ�/����/������P�����<�,[�߲�Ʃ�gK������scw߱�@.��pK�!�y��)�G�, {^�e@ae�;m]墭�u���Պ�V���i��Z��Q�E%�S[Ec9+�ё���`���j�<�N���0�P��TiVhm��z)��ӗf��y�&��'>^�҈���օ8e�;��qS�:_ ��0`R��?a~�$��PWKUE҉ٶ�bN��w��1���(%g�)��Y�&��p�/�R��m��^ľ*(�T$�Օ��Ժ��eC�G��]�KN���qmώ-k`y�b��#��`��a�������Bo�gvw>�2=�8-�9����ő����>:�������Lb�}��4�������6]<�gZd�wO����/;����I��{A����H����#��w��_tHw���M\z�s�gSAN>&tB���E�.מ���?�_w�y���n��#J�u����LN�鏃�˃�?&w,��Z��ϛ�����y��>%Q�q�}��������q_��4����������q	]�7�zp"�sq�	�7�������F��^�O�Fs��=�~g��T��4���c䤯v��	=���?;W�$r��Ozd9�t<Z���39��	�����U�އw���s<��lx|����B������������;�����;����UrT��-�$��ݧ�;���|��H* �m��u�?��>���:y[�����|�n�^}�%�jy^?�f�6����	�<���Jvs\CK�Y��x�_�s]ǵ�u"o�������;�R���7�8P���p���k-H?��mt3��4���k����k��skrvg�=�O�y���L�M3 ���^:��~�7·���+���I�L�kaN��0#�X|n<�g�&��ɪ����)%-��"���Ɠڽ��N�����w�v��ȏ���I�	�0��څ_R�ûW5�2=�;��K����������>
                           ���mM� � 