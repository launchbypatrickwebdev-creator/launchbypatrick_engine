import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { PDFDocument, rgb, StandardFonts } from "npm:pdf-lib";
import { qrcode } from "https://esm.sh/qrcode@1.5.3";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// 80 KB Base64 Compressed Logo (keep your real logo)
const LOGO_BASE64 = `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iCNWHYelSNFpxxv65CADE4/5J+uU/tcYJC2M/FUHQJSfwCaVChzOOwcgyQEBo0Bdxl39XdFjxgwm3IoDyJm6VtAtxRlEUtNWAeCjHcy7U/ao1TeAr3G+fe822ShQKC4OxGqynam50m41y20I2N2Nvd2JpYqI83mByi4/S90mO4/5S45y3m4s0S231mS33y80A6O85/M/sXmbb5iP314k2y0q17eXyXfU13233w0m8E6z8v0h/a6jHl13+2O8c8h38x093v376/GqM36/S/3r0O/e98t6j6x/8/a9/3P3oH/9A7v7bI5/v3rL/1u3vvv1A5L/33m46344H6+1v5H1S6sD0S250+sT48R3m20f1aJ5N+907n7337lcvff/qGf3223t/vP31q199+e43f1C6ff/Ld23e59uP3l2b0z/255530u/u10/xR4P0fTfbO7/89f2fvvhC//iP3//41bfv0v334sI6ev5+7Y2779x9+4f3/tbf/ef+3mcf/m1I7Y20b9e2+41m5UcfvP/i3S+++9e/Hj56/9e//vbr20f/8b111+sfe3/vh0ff/++9v3//A9f/y3u/v33/x4/e+44m7/pL23+/86cffvvq+69e3p2b/v/u1R/ee/vj60/X4f9+9e/ff//99z99/d9f/2j/83u/v/OXLz/88MP3332s9d//ePf/3vzX2++f616v/u9X3/7x/u93v//++/devX23vvd/r/35q59+/uOXX/34X3//8b1vvtX79b9409+vfv2fv1/55r133/vpt3///eeff/X3d//0f2/e3v/13fef+5314v/+9vcf/uXdP3/17Ufv/3v1L/3jL7///vv/fPfD8N7bX71/sXf7f/7x83vv/fTzT1989fcv3/vL3X/d+fr3f/vlhx/efv/dd998e3m/p6v6r//4/s2///j1b3/e3fv35+9++MvX9x8/evT+++8e/fv3f//83y/v3Pv2x5+++uX7n7767Ydvfrf3X/e+++bdX9+48sXb/3z3v4++e/32619+/O3X3/+X1X/3/S//fffe//Xjdz++/5fvX/3y9sObpTj813+9/fK/fv2vd79+89u9T/4//3nn5dd+/nnHH3/+/rvX3v3+b3+72/yfv/vll5/vf/n1d5+++O39H/7n54ff4L4/3vr95++3/vLTrz/+5fs//e//f/veo/e/e/f//ufx3Uf/eO/vv/zxyxc3X7//j3///e++/vaX///+9e/++ee7999787ffX75x+2233v7XHz//8cv/vXvz359++fHl333xzb///X/fvPX2/2///u+/P/7vX/7y6N93/vj/f33/5v2Xbr734RvvvrH21ttvvfv/f/fX26++du/fH/z3O+//9fO/f3nz1V++//nrr9//9t5f7935y2tvv3Dzzf9+4eXvvvvm03d/+eOnn9/+8aeff/n51S9vfffdlz/++3+99tr3f/rxx/e++Pztt1597f+88trL77/x5utvvvL3/3nzN/f+53/+7bfffv+///iXX967+f4/3rrx349u/fTdrffvf/vhg9+/98vPf/n+/u1vXvn+DzevfvaPD+59cfP+e+///sbb3/329r///vtf33/3ly//ef/mD3/75euv3//jTz99+M2Pf3nvN++/ceONF3547qWXrvy/F57/j1euffuPf//32198c/PP/7h//9vfXfv5ly/fev2l/3juhedvfPj+B9fefOftd999++Zbd+/+4x+///i///j6+X/c+fXb/3n3m3v/+eP/vPXa62+++fofX/vft+9ef+sN3f+Fv/30xbe3f7v977/eef2Nt15/9b/vvvr6Ky8998xzLz3/Xzf+87/f/e7117/747/v3//vH7/64d0P//vD/e+//OEPf/33GzfeePOn52/8fO052P4E3P4XmF23/f0qAAA3vX5p69oGgj/++OOPr3586z/fvvfO22+vfO/Fp5988ukXXnrpxddeePbpJ5+u3Oedn843p6uY0d2f/xX/t2o/X/35z2vvvP3aC0+vPOv4P2688fob1x+v/O6v7v+4evfXy3/5l99/8c2dr//9z/fe/e9bb924fOWFf7p1683nn372iSeeefq5p55/8vET/zU846y3/28p/X/43bUfv3rt/42H7t9885XXfnrjpxu3X3/xGae9/p/3L/33n+93/vK39/4/0XvXfvj1v+9+//r//P3++9/ceOXN3/10/d8vvPTk0yvveO3ZF16/fS4/q6d2//v/3/v3+u8/XnvzDde/vPTSS6+/eu21N3984dprrz4X2T+//43p3r3/20/vvPW326+9/eP3b934+drf3njlT/98/ZUX/vvi069ef/1mcvO6m4/79sPv7m393s2fbnz7xT/+9v1PLzzzy3NPr27s6f3f3rn3b3e3fv7d1s9vfv/99f+1/v6vvvr211+u/fj/rn23dflfPzz2mvd/u/7f19796Y8f/ev32/99440/XP/+7bc/fvv3d1/878+v/Xz3/Rsn//Sfv9/4++uvv/fD7bc//O073QpL33433/1/1+/ceeedv/zX/x7v/Xv1D51++e2NN1955vS5p++//v4vr3/5s+f/+7mff/v+v//3m6/ee//qF1+/s/Ivx1f/fPPvf/3fW7f/fvvdF6/95S9v/2vtXv/1l1/e/fvvH/zu23feffmPv9969oX7f/m3P33z77ee3b4J7x8/XvvzO3/5p338X95+/f8eX//5//z+mzt3/vD2/e/fufPvd9+5//dbr16/8uX1H9+4efuXN2998+m/H775+psv/fD9P+/e+f2dd9659f13v9955y/fvvvm7e//+cv1x9bB/8O///31f/z3y3/dfuu//vD2m6v19vU33f9//s9/+8O7f3vvhxtXXr/+72vvfvDdd1+vI7mH99/87qfn/v7jV+/ceesf9/9w6y9v//bLre++eef3a398//v/vPP9L7+/9c3fb716/fe7d969ce+dP91+99vf//Dtt2+//S5N6O33L7//wX9f/unv/3jrrzdevvX1j3f+fv+H/33ttbt/ePW/Xvz529///uOff/zhhx++/f6PP/34/a1/+8NfvvjXHz/+9Nvf3vvptat/feMvL3//t2t/+ef3X//trdf/9frbP/7++e23v3vv3a+//v2v//3hh+/efuvrN+44+fvvfnnvJ2/4993vfvfP33/96v823/j5p9+++Nvv3v3H5f/+5/u/f/vrt/+8eeWb55/9218++/GfL/3m11eff+7293/+/u4X//j2lX+//p9/u/fWW//7/tffvf/rD+++e+/dd3/+77e/eu2V//337//yx/e///71tzde3mfe++/f+e7bf93+19/f33p19X//9tOvf/nvf7/8znd//v6fb73199fffvE/Xnv1h++/efutN1//3x/f+/3dP//71S+uPvro//s/37zyf+//+PXX31/984/f/v7hD3//1xs/ff+f/3v3H9/+9vd/+X+fffbO+zeff+Wbb//znS++/9evN6/euvftm6/cvPPOX974w0sf/Pzll9/+89t3b//tzZ9+f/n5lz/4r8///u43X/3+/Q++/s9LP979841bb/7zD285/19++/yPf/zX/b//30tfXfnrnfev//jTz3f/+Kfb33/7f7//8x/3/njvhz9++cOPb33xyosf/vDDT2/c/OHWtx++9dbbf3j//U9f/eH6Fze+/O/Pfvj95jfffXjrX+8+/5v3/v2Pl/4pE3/x9r8f3bvxD/d//u3m+x/s3X947Zuv/8f/Xb3/l3fefO8///f3N/7+p39ee/l/f3jvx29fvfX37/74+9/fe+2H517+/O3//S8vH9p++vK//vq3l3+49a/f//jHq//94//++8c3P3/9z9/eeev1u+9fefOft77/x9Xf3vvppS+vPvrr2ze/fveN79/+x9tvvfbaey+//pfr1/924/1v333/q88++NfPz73wyze/vvLll9c//P77r397982vXnnl3ptvvv78D2/de//fv//4s++/uXXvvfdu3vzXdzef++W/3/nL3//x7pt/e/evf/n2O53/m9d+/Ovf//7u5S+/eOOnr3788+1v3r35v2999tq9m6/+8M+fP/vww5f+/fcfbr/082vf//Cvr7/+x3/9+O5bb924fPvWW298f3fvxo//eeWV9/7y2ksfvPXWW6///v4//vrXb3/89f+9df3/3v7hTze+/O+/3PryjTfu/m/fX82N/s4qS3i411p+v6/f/3pX/f3mP/7+x6/f++35/3rm01/++eefX3jtzbce/d9r/3f954f/c+fOnVs3v//s/ptvXXv1lT///8vPvPf3v938/sPP3pS38Nf/fP+/1x/cvfLfv33z/Z2fXrt/57m3vvjhyzeeffY/Xv7vG+9ef/K433/5j3v/uv2fH79753+/effee+++8t83/s+L1/7Xq6+++sq/X/m/X/313Z/+cvX3tz649o/nX37pA+93952/vvv3m9e/+eHdrTf+/L/f3Hrr3//8152fv3v3/Qe/+9e12//+w4f3fvv+rz/+dO29m3+4/p/vfvef7z0P1k8/vPvjZ1f/4/3/ee4/nrr+lzc+++y1b569+ffPnr/y1j+uv/Xp1VdeufLdt69duX3rlVe+vHX3yutXvvvhyq2/vPb0H//z+x++mF2C4Z+r9P3X5/987a03/nnl+7+/eS+m6dO//+On4/0sH3/588tf3Lq3/d39/3v5m//46e/9546f3/rujS9+e+/u939763dv3XnrO4O/fv2V/7v0p+eefuXmm6/875/efOf+35+/8s8b1/91//a/fn3z7R+ue//mB998dOudG3def/k/3/v3G6/f//v1u3/941/u+s/dd197/c2/f/fN/b+89trP33/z0s93fv/qP9+49efX/nnjP3du3Hr/2nd3br1x9+0/P/e/V7556fZb3x/9p6t/v/HWLz++e/vv199+5ZXXfvrLd/f/4//+9p9/fOfXG6//+90f/+O9Lz+98trL/3/y4a0rt9+6fevL7+/9++1vXvv366//7+2X/v3/nv/f5/7rmd/8+s39b+5c/cfvX79685tnrv7tr//+/J1vf/v3i/9x+dWf3nz9/n8+/eGllz/4y/sfbN24fv3Ktbv3f/f5F++//5/vfXv/73/452tP/OOnrz974+b1/32u7t9492f3b3929e47f779j7//4b3vf/vxre++vf33X/4T6+8XXnjhheeuPLf/m9u3rn13f/Xmlyv3/+/mS1/948Yrn1/55r9fffOtd/7X9z+8dO3F/5Ovv/vWfX/74e0f/3r/zbc/+OW5m/fe/mDvw3/f+/vv//r9t3t//f3H6zf+cf3/3fnrn3ff/efzN77++m/ff/XqC9//3/fffvPj3z///s+//fjj/Z9/efmX31948x+ffXvr6e/u3Xp3b33/zZ+//PXXe+9//d3rf/7H88/f+/N//fjj1y+/e//2L7/v3X37xvevvXTt/bd++/a15278440rn1/9z6uvfPn/nn/++df+/tJb3//+/e+/vPPznz5+/8//vvLmW2++/sb1l67eefu1tz576aM3/vbX43e3X33m+s179+/d+u/v3rj1yve/ffvv9//6t9ve/3739jtfXPvuu+/2/uf651//y5Wv3vn7vdt373/25vev33v5m7fvePnGq+/de/4fP//iizfe/e4vb7135X+99N/Pf/X5m1+++srrD197771nn3vu/7p733Xvvvvur3/7/rWr3z+/dffKzS9ufvf3O7fuXXm+a/eN23fevvn/Xrrz7u/f3/r5q6/uf/XWb+//+Kfb9++9++tf4bvvv3f7yptfX7t147P/evO1//35P+9/98bNd+59fOW396/8cO9v/75y8+Uv//qf793544+33nn21ltXfv/9e39665/fX//bna+/ee/Xtz/48aOff//3q3/995U/vnrzlddff/4v194/x/ffuHP91vUbd/6/L/95641//+PzL3945v+///r3v73zzssvX7n/xuv/uPH9P2/fevvP33z35muffX/vh6++/fftf3/5/fevv//Kq9ef+2/73iuvvv785/fev3brm3ff23vwX3/4/KXX/v7Ttef/+srrL778j3ef+9v/vPr1m3+8/sVvL/3l5T//8e6/vvrmyzeevfaPf33/u3++ef/N77/89N//eeWf/3n5rXduvf7a3++/deul79/+6XtvXrm/297vvvv399564cZ/fPL0i7f/+cptn3++f+9ft56/efv2K3/87//8/Nrtq9d++erq//n4y59fe+b43v3vv/3H7f//pX+/dOefN365eeXmd1fu//XmS3/+/f/eef2Nt//S55evvvbfb/3X3Xv3vvrx/ltvfXbvA3v3/33z3Xdf2fvvX537XzdevPH5//vjly99+/3LHzz13IvnOa633vj8v73x9I/vvnvnzndf//P28/e//OHq5f939V/33/vd63/+01tvXH3t2rUX3nnm5v3bbz+ze4d2fvv6y7ffvfPqE//7wY+//u3l7//648vf3fvh3m+/vvPee39f/b3333v3e/3953e//833H958+Ztbv/zx3l+/fOfX3y9//eF/3vrX9X/dv/3dd/e+f/v9q3/+e3f3/q++/vefvvjtzp8/vfn6f9z8y7v33vrmXf338t/v/u1/v3v3z4833vv9H9988+1v/v72j6/84683P3/9zV///S+/3f3+rR//7b++/fP/uvnll+9/+eU3V567c/eddz67fS/M8cI/b9y4d+efv//+5o333/m3/3zz//z23Xe/vfH5yvdv3bj5v//513+//vaN+/+69eYr//e/3nn32v/+fP21T/75zVefvv/zW5+/ceOPL//H/33ttb3/+/rL3x+//9m//f4/7vyfL79++cYvd15++a23fvjy73e/f+fNNz64cevlz33+/Euv/PL/3Lxz+843195+e/X/3nnlh1vXvv3n33//8/tX/u+N/3vrm1/++d3LL9z9/oOdr/742/v/eumHf75+/3sv//m1r39884W3/37rrV///o///88vf/jh/Tdfu/fdtS++/OHm1VuvvnDnz1d//fX7795++a9//Pftlz/+3X9fuvvD/dfufXv//b2/vfH83Vve973vv/vtr3dufPb1tzdvXvnrm//1v2/++Obtt/+xf+/NN99++f/4x7uv3vr+53/fevuN71/7+v1nv/v6mzvffvfmm2//+fN/X/nn9/fvXfv183++fvv/3L/5v299/dJLL17//aM//f3/vfPO3/fuvHnzxs33f3njA59+4+27N7/58st3Xn7z4a0/f/P/vv36d3feeeebl1/+6oUbbx/5u34///0/3rr752v33v3y9Tde3X//2rtvvfv3f9589dsv33vrL3/9fve/7vz59i//uHLv+8/uXXv++fuvvvftP376w+vff3n/zTd//urO2++9ee2///ftb/772y8u/edLL95+7oX3/vLOu7/96+///c9/X3vxP+/eevLvf/3739+8/sHLL7/13R9u/OPlq9d+9+/f3/nj11d++PGd37/+r//z2ksv/PT6L3e++/4fd777y493rrzx99s/33z3p3v3nr/+y//+4827N+/+eOPlL7783u+e/2///eU//uv5X964eefatfe+/eetf1x5+/Yf//fV3fdeuPLdrbe/euXatfdevvHdt//+6f/8X3e+/u4rf73z3a3/fufm3+6+9O1//vT+mzf/e/3GZ98s94t/ffef/3nrj1v//sPt/7l35y+fe+7m3f99/p2/f3/r9ddv/OP32//y9o/ff//+f1++/eefr/75h28//eeXN1++ef3+tzf+6//efef/3PrL/b989+d/fvbZZyvff+O5f/+fdz9799Urf33r+v/evnnvxeve/eevvfv5ze/uX3nl+m+fX7l15aev//Sff3vv+S///s93/v3qKze++/3X33/+9kuffP/58z/8/p9f/vbX3//0wzdf3Xvjxe8+uPfev/x2++fvvnv//i8fffS3H355670//enWWy/+1z8/+eOnrz3/y+1/ff/D//30089f3rz6xjs/vvrP//3Xp1def+m5f//+2xvvv/f+nd9///vL/3zzr7//++df3rt/45tnrvzpHzdf/+9/ffPdrR+++OLdP77+9ss3//vOn99++c/vv/vJp/deunbvX3fuvffev/z/v3/79fO/f3n9q7deeeG93399/YtPv3/lxfd3Xrrx0f/efOnW7fvv/fnvv/9w+6ff//X7y/vv/eu5u++/f+3m5a/vXrn7u+/vPPX5Z3899f8/eeGvN69/d+/dd6/+cf/O8589//+689s3vvv/f/f0s99e//Lef147cfu+P4MnvPve12s/fP/+/esv/f7//eOfN6/cfvPNL/957xuvvvz2yy//x3e3f/nhu/9+9L/+8O63f3/nh+u/+4+fv//9mzt/ffXq3fdvvPPyvd+/de3Xlz/3L/m/v7n/v6++/tf/9Oa/fvr53zded3rL7y/cuPv+F9deeum15545f/2F13/46c93/nPvyrt///Otn757+/1rr7x6+zevvvvdn15783eff3jvxr3vPvj35aefp+3vI/+69t+//fa3X3/+S//Gjfe+e23/uVf3/nHvl9dvvHvvxe8/v/mP/fcv//mdd/c+/9er37z14zvvXfn2S59837f++f/8eet/b149cePlb2/efuvG//3x7XufvfXmzc9f/eS/3v/1u++/v/PnP7z50o133/r+9Wtfv//9vTf+de/+/eeeeeHvf33rzbeevv/j+z9/duubmzc/+On6c6///M29D1+9+873rz334w9fvfeX+9++/8U/bvx6/913bnzxP//4+stvnrr39vuv/vS/r/3y2p0rL/43nv/u61efXHv/2r9v3rvzr+eff3nvX/f/cv/G399++dYnX937t5ee/vj6a/s/vvveS1d+uXXlz3vXXrty8/Z37119/tXXbnx4/+2/fvP623/64v3vfnh4/3+ff/fdd393/O77b/9x4/vvf/j5X1///a+f333l9VdvfXPry/devfbeS68+c/27O3e+/fnP37/++j+e+88vPvvsn//84zsfv33n//3xztvX3njjtRvfvvnT9de/v/nm988898q3f/vu2k+v3H/z8788f/X+p9fuffu/nnv281t/+etnn3333o++/+u7f/3rn2/s33/r3de//fbfX9x57bkbv/7puzff2v9N39x94f/44d9/+OPX9/4Hef/x8d33Xv36m1uvXX/pL3fuf/aPP1/d/+3ed/+v0w/vfvf8j1e++/LqX+789r/mNff+7vffXv/zC3vfe//Ouz9+f+X2S3/46y+vv/75h28//eeXN1++/9OXX/72+S8vfe7/uL++f+12e/29d2+9/PInb//++rtf/Ouf77zxxvdv/OfvPz536z++/erqF5++fuXZd/54/a1vPn/rmdtfXvvu3v6tO//fGf9uXv3Xv/7tzqtfv/P3z15/9bdf//rmndu/+N+v/Pefv//+r3e+/8s/v/n++f3bX7z3mze+/+mP79x65atvvv7h39++/vbbdz9/e+e/b/z3N7d//vj+93s/vvbZ1d/f++e3N2/+e/vGza/u/ef//PijrT88/9Jbb914560fX33rmU/f/fS//vP/9158/a3vvvrx53/c/s9L/3Pz5s3bL//yze3v/vXnn1945pUX37t86++fvrJ/9dqdV1++cuvK1f+6/871n3/64P/8+o93fvju+/sfvffGq/v94sbfX3/tnS++ufbll+//66dr//j443/7+a8/v3Prm993S3EAAAAA0Ie9M4ttHIbC8L3/f7I8kMQ4kZxEiUOC96E5sQ5d6U6H0q4MAtIioEUSkAYXWggqXfXeY+x49+AByQ3UogUUS0AUIij/XWwI23Y2O4E9qO34/A9817eS3a3s10e194A232kX39401n+fS/3990OtbkR33/321tZ9H3f17X6y9m+6f654bvdEsd13z+i65rS27rtq366rprpt23f/2X/t3fN819f/vvrmS6u/9nLvv8j0x3pL+9m30+2G0r56U7605P4931m65y/5Ie1x1f343e069yJ3/3q9/e0a+3x4eE/v++L+b27e997U5f992L1p6S/8p0aT34t+/2NfN9y1vNdeS7n7Ien9eH6vP2j24z/k40x+1f2X2n+b9qE81Fm+7/84l032vWvH5262c8/L7/V6//i/3133s8f2+2xL77O3/fbf0l8a1M2+O/37x+2++37qfr4z/aW5796a3l8i2++v2u1P/b28t++1p3j1q69Oed+/v3vj0t//G9/67/7fU1p3S2Xf1qX3f5X4/88p/A+oG0i/X16vFz99/mZ57p8uTq+eX34Uf12e/7v1l34/9XkIInx8vnh/e3l+fl10s8/vA+3v331/f/724/j0sX1Svnz8vL/c+/kO9a8vX/evX8fH50X9/vH1eX5y31f3T/fr9x92f/X3t73mef91937f37/+fr1u7s/fLre/eP6P19uL22dfl7+/f/fD33vjS6s+/3d7890/fH3/cf/2efs3fPn4enx9eHxe3D/9+e/zPfr20y22l9un89Xbxf3Tf/lT6t/s+O+e3P+z2u4f4347Xn68/Sj+ffx+/j/+3I8/+b//4/v6/eP49P5e/Pn+sUv6RfvX9uPzvv+9/mP3+38s5Xf985++94//9vX97eX55/Xxfj/3fN3/bE+//mR6fr2Xn+6m133uL6a/uO0f72/9m4iIf+C/8o+y31v5L/A3/N7/zT2e/b7/x363Ovf8+/7s/u5zX1/f73/sU//3s1+3Pxfp/3vM5a+ff/e4f/6+r+afrs8/d356fl++vn6e377eDxf5u+eX7y/t+3t/bX/3X//p474/e33d/yP5/eOnq8d1dfv3m3fS1bI9nF3e1rI6133Tq6X13p5sH/drb54v2tf9xf3z43L6f3D/4P7fI4xP//9mIfr3+M/x+fbvL9P//Xm/vn2+fJ3uL1fX7zP1L355/s8vny7e/9vf/3i9fL68/X14/fDxcLq/f5y+/+l9Xv/+q/2I1d+qX/X/pI/6491i+3E9//R4un6+evyYfvvz5v709e3p18vL5aO3l+vTx0f31+3H9X+kff26v97+q13ePz/ut6e718en5/3D5/f0D+e3L9+v19f/lD/1Xz2+v18/1v2f36vj68fz6frx/n1/fLp++Hj1+O+S1O+/u/6b3f/i8/p6/3J8+nz5dPn84aP76+vT1f37h8unq4/+/f/3t33+N4v128en28eHj49fT9dfH39fv1++/n11ub++3f/1+s/+3S9/t/v38vD988Pj08d9e/s4vb30V3fXz++3f3D94+e7y+/21f3j+3X+5/r3L59+ut/+2T6Xvj/e9v8m/b+/+1f//3a5ev8+fD/3X5fXny9f/X76dPn09/v0258/m3++u7m3y4fnh7urP1fX16eb58uHu6ufLh/unm4e/fJ5e/f/3p4/Pj5fP//Z/vHh3/+/+fSj+X9++1v/y5/f+p8/v/+xS/t+ufh5+/j6/Xh4+/zL5/vXl4fH328vXz++ftv/3b99urj/+f/1/O6q/48vv/74f3t5vf/fLh7u/qE/3f/h6e724u35+vP3X4/X1/urj8ePt29Pt8/fL/9312+/3z4fHj8ePv356v9S8/9+un//XN++/ffk9ur6/ev9/eO/r54fL1/ePv19ff883X6m/jR1cf/32e3N338xS/vv/3X++eXh+/Gve/q/v2/4v91fXX3233211/+H9/s3/8f2c3P3ePf/xX0f1P9e//e+S9/+pX3e/u73m8/087v8N9f/02+/x6s379d/d44f7y4X35L6/U/66vH928f+3/Cnh6evd3c/v2P/9O8/1N8d3x6u3x6/3z8+vP2p86fHp5v/z+vv/307f/v4tNze333y49O6p3+I/48AAMAtfF+r0/4XAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAM38AYg1v21m4J4hAAAAAElFTkSuQmCC`;

function formatNaira(amount: number): string {
  return "₦" + Math.round(amount).toLocaleString("en-NG");
}

function generateAuditId(): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let result = "";
  for (let i = 0; i < 5; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return `ELS-2026-${result}`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload = await req.json();

    // Required for email
    const email: string = payload.email;
    if (!email) {
      throw new Error("Target email address is required");
    }

    const audience: "generator" | "fleet" | "both" = payload.audience || "both";
    const organization: string = payload.organization || "Unspecified Organisation";
    const location: string = payload.location || "Unspecified Location";
    const dateStr = new Date().toLocaleDateString("en-GB", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });
    const auditId = payload.auditId || generateAuditId();

    // Metrics (same defaults as old code)
    const genCount = payload.gen_count ?? 5;
    const genBudget = payload.gen_budget ?? 200000;
    const genLossPct = payload.gen_loss_pct ?? 15;
    const fleetCount = payload.fleet_count ?? 20;
    const fleetSpend = payload.fleet_spend ?? 120000;
    const fleetUnaccountedPct = payload.fleet_unaccounted_pct ?? 20;
    const dtHrs = payload.downtime_hrs ?? 8;
    const dtValue = payload.downtime_val ?? 50000;
    const staffHrs = payload.logging_hrs ?? 10;
    const costPerHr = payload.logging_cost_hr ?? 2500;
    const loggingSites = payload.logging_sites ?? 3;
    const emergencyBuys = payload.emergency_buys ?? 6;
    const emergencyPremiumPct = payload.emergency_premium_pct ?? 25;
    const emergencyVol = payload.emergency_vol ?? 150000;
    const adulterLitres = payload.adulter_litres ?? 2000;
    const adulterPct = payload.adulter_pct ?? 10;
    const costPerLitre = payload.cost_per_litre ?? 950;
    const multisiteCount = payload.multisite_count ?? 5;
    const multisiteLoss = payload.multisite_loss ?? 30000;
    const audits = payload.compliance_audits ?? 2;
    const auditFindingCost = payload.compliance_cost ?? 500000;
    const auditProb = payload.compliance_prob ?? 40;

    // Loss Calculations
    const genLoss = genCount * genBudget * (genLossPct / 100) * 12;
    const fleetLoss = fleetCount * fleetSpend * (fleetUnaccountedPct / 100) * 12;
    const downtimeLoss = dtHrs * dtValue * 12;
    const loggingLoss = staffHrs * costPerHr * loggingSites * 52;
    const emergencyLoss = emergencyBuys * emergencyVol * (emergencyPremiumPct / 100);
    const adulterationLoss = adulterLitres * (adulterPct / 100) * costPerLitre * 12;
    const multisiteLossVal = multisiteCount * multisiteLoss * 12;
    const complianceLoss = audits * auditFindingCost * (auditProb / 100);

    const breakdown: { name: string; loss: number }[] = [];
    if (audience === "generator" || audience === "both") {
      breakdown.push({ name: "Standby Generators", loss: genLoss });
    }
    if (audience === "fleet" || audience === "both") {
      breakdown.push({ name: "Logistics & Fleets", loss: fleetLoss });
    }
    breakdown.push(
      { name: "Generator Downtime Cost", loss: downtimeLoss },
      { name: "Manual Logging Overhead", loss: loggingLoss },
      { name: "Emergency Procurement Premium", loss: emergencyLoss },
      { name: "Fuel Adulteration Loss", loss: adulterationLoss },
      { name: "Multi-Site Oversight Gap", loss: multisiteLossVal },
      { name: "Compliance & Audit Risk", loss: complianceLoss },
    );

    const totalAnnualLoss = breakdown.reduce((acc, item) => acc + item.loss, 0);
    const primaryRiskSector = breakdown.reduce(
      (max, item) => (item.loss > max.loss ? item : max),
      breakdown[0],
    ).name;

    let totalAssets = 0;
    if (audience === "generator") totalAssets = genCount;
    else if (audience === "fleet") totalAssets = fleetCount;
    else totalAssets = genCount + fleetCount;

    const threeYearLoss = totalAnnualLoss * 3;
    const unaccountedLitres = Math.round(totalAnnualLoss / costPerLitre);

    // ──────────────────────────────
    // Build the professional PDF
    // ──────────────────────────────
    const pdfDoc = await PDFDocument.create();
    const page = pdfDoc.addPage([595, 842]); // A4
    const fontBold = await pdfDoc.embedFont(StandardFonts.HelveticaBold);
    const fontRegular = await pdfDoc.embedFont(StandardFonts.Helvetica);

    // Color palette
    const emeraldGreen = rgb(0.0, 0.9, 0.4);
    const darkBackground = rgb(0.04, 0.06, 0.08);
    const cardBg = rgb(0.08, 0.11, 0.15);
    const textLight = rgb(0.95, 0.95, 0.95);
    const textMuted = rgb(0.55, 0.6, 0.65);
    const alertRed = rgb(1.0, 0.3, 0.3);

    // Top Header Banner
    page.drawRectangle({
      x: 0,
      y: 762,
      width: 595,
      height: 80,
      color: darkBackground,
    });
    page.drawRectangle({
      x: 0,
      y: 758,
      width: 595,
      height: 4,
      color: emeraldGreen,
    });

    // Logo
    let titleX = 40;
    try {
      const logoBytes = Uint8Array.from(atob(LOGO_BASE64), (c) => c.charCodeAt(0));
      const logoImage = await pdfDoc.embedPng(logoBytes);
      const dims = logoImage.scaleToFit(45, 45);
      page.drawImage(logoImage, {
        x: 40,
        y: 778 + (45 - dims.height) / 2,
        width: dims.width,
        height: dims.height,
      });
      titleX = 95;
    } catch (e) {
      console.error("Failed to render logo:", e);
    }

    // Branding
    page.drawText("ECHOLEVEL SENTINEL LTD", {
      x: titleX,
      y: 805,
      size: 18,
      font: fontBold,
      color: emeraldGreen,
    });
    page.drawText("ENTERPRISE FUEL LOSS EXPOSURE AUDIT", {
      x: titleX,
      y: 785,
      size: 9,
      font: fontBold,
      color: textMuted,
    });
    page.drawText("CONFIDENTIAL", {
      x: 480,
      y: 805,
      size: 9,
      font: fontBold,
      color: alertRed,
    });
    page.drawText(`ID: ${auditId}`, {
      x: 450,
      y: 785,
      size: 9,
      font: fontRegular,
      color: textMuted,
    });

    // Metadata bar
    let y = 725;
    page.drawText("Organisation:", {
      x: 40,
      y,
      size: 9,
      font: fontBold,
      color: rgb(0.3, 0.3, 0.3),
    });
    page.drawText(organization, {
      x: 110,
      y,
      size: 9,
      font: fontRegular,
      color: rgb(0.1, 0.1, 0.1),
    });
    page.drawText("Location:", {
      x: 260,
      y,
      size: 9,
      font: fontBold,
      color: rgb(0.3, 0.3, 0.3),
    });
    page.drawText(location, {
      x: 310,
      y,
      size: 9,
      font: fontRegular,
      color: rgb(0.1, 0.1, 0.1),
    });
    page.drawText("Date:", {
      x: 460,
      y,
      size: 9,
      font: fontBold,
      color: rgb(0.3, 0.3, 0.3),
    });
    page.drawText(dateStr, {
      x: 490,
      y,
      size: 9,
      font: fontRegular,
      color: rgb(0.1, 0.1, 0.1),
    });
    page.drawLine({
      start: { x: 40, y: y - 10 },
      end: { x: 555, y: y - 10 },
      thickness: 0.5,
      color: rgb(0.85, 0.85, 0.85),
    });

    // Executive Summary Card
    y -= 30;
    page.drawRectangle({
      x: 40,
      y: y - 85,
      width: 515,
      height: 95,
      color: cardBg,
      borderColor: emeraldGreen,
      borderWidth: 1,
    });
    page.drawText("EXECUTIVE AUDIT SUMMARY", {
      x: 55,
      y: y - 18,
      size: 10,
      font: fontBold,
      color: emeraldGreen,
    });
    page.drawText("Total Annual Loss Exposure", {
      x: 55,
      y: y - 36,
      size: 9,
      font: fontRegular,
      color: textMuted,
    });
    page.drawText(formatNaira(totalAnnualLoss), {
      x: 55,
      y: y - 58,
      size: 22,
      font: fontBold,
      color: alertRed,
    });
    page.drawText(`Primary Risk Sector: ${primaryRiskSector}`, {
      x: 310,
      y: y - 36,
      size: 9,
      font: fontRegular,
      color: textLight,
    });
    page.drawText(`Assessed Asset Fleet: ${totalAssets} Units/Vehicles`, {
      x: 310,
      y: y - 52,
      size: 9,
      font: fontRegular,
      color: textLight,
    });
    page.drawText(`Operation Target: ${audience.toUpperCase()} OPERATIONS`, {
      x: 310,
      y: y - 68,
      size: 9,
      font: fontBold,
      color: emeraldGreen,
    });

    // Sector Risk Breakdown Table
    y -= 120;
    page.drawText("SECTOR RISK BREAKDOWN", {
      x: 40,
      y,
      size: 10,
      font: fontBold,
      color: rgb(0.1, 0.1, 0.1),
    });
    y -= 15;
    page.drawRectangle({
      x: 40,
      y: y - 5,
      width: 515,
      height: 18,
      color: rgb(0.93, 0.95, 0.96),
    });
    page.drawText("Risk Vector", {
      x: 50,
      y,
      size: 8,
      font: fontBold,
      color: rgb(0.3, 0.3, 0.3),
    });
    page.drawText("Annual Financial Impact", {
      x: 310,
      y,
      size: 8,
      font: fontBold,
      color: rgb(0.3, 0.3, 0.3),
    });
    page.drawText("% Share", {
      x: 480,
      y,
      size: 8,
      font: fontBold,
      color: rgb(0.3, 0.3, 0.3),
    });
    y -= 10;

    for (let i = 0; i < breakdown.length; i++) {
      const item = breakdown[i];
      y -= 18;
      if (i % 2 === 0) {
        page.drawRectangle({
          x: 40,
          y: y - 4,
          width: 515,
          height: 16,
          color: rgb(0.97, 0.98, 0.99),
        });
      }
      const pct = totalAnnualLoss > 0
        ? ((item.loss / totalAnnualLoss) * 100).toFixed(1)
        : "0.0";
      page.drawText(item.name, {
        x: 50,
        y,
        size: 8.5,
        font: fontRegular,
        color: rgb(0.15, 0.15, 0.15),
      });
      page.drawText(formatNaira(item.loss), {
        x: 310,
        y,
        size: 8.5,
        font: fontBold,
        color: rgb(0.1, 0.1, 0.1),
      });
      page.drawText(`${pct}%`, {
        x: 480,
        y,
        size: 8.5,
        font: fontRegular,
        color: rgb(0.3, 0.3, 0.3),
      });
    }

    // 3-Year Forecast
    y -= 40;
    page.drawRectangle({
      x: 40,
      y: y - 45,
      width: 515,
      height: 50,
      color: rgb(0.97, 0.97, 0.97),
      borderColor: rgb(0.85, 0.85, 0.85),
      borderWidth: 0.5,
    });
    page.drawText("3-YEAR EXPOSURE FORECAST", {
      x: 55,
      y: y - 15,
      size: 9,
      font: fontBold,
      color: alertRed,
    });
    page.drawText(
      `At current unmonitored loss rates, ${organization} will absorb ${formatNaira(threeYearLoss)} in unrecoverable fuel costs over 36 months.`,
      {
        x: 55,
        y: y - 30,
        size: 8.5,
        font: fontRegular,
        color: rgb(0.2, 0.2, 0.2),
      },
    );
    page.drawText(
      `Estimated lost fuel volume: ~${unaccountedLitres.toLocaleString("en-NG")} Litres of Diesel.`,
      {
        x: 55,
        y: y - 41,
        size: 8.5,
        font: fontBold,
        color: rgb(0.1, 0.1, 0.1),
      },
    );

    // QR Code + CTA
    y -= 130;
    const connectUrl = "https://echolevel.vercel.app/sentinel/connect";
    const qrDataUrl = (await qrcode(connectUrl)) as string;
    const qrImageBytes = Uint8Array.from(
      atob(qrDataUrl.split(",")[1]),
      (c) => c.charCodeAt(0),
    );
    const qrImage = await pdfDoc.embedPng(qrImageBytes);

    page.drawRectangle({
      x: 40,
      y: y,
      width: 515,
      height: 100,
      color: darkBackground,
    });
    page.drawRectangle({
      x: 40,
      y: y,
      width: 5,
      height: 100,
      color: emeraldGreen,
    });
    page.drawImage(qrImage, {
      x: 440,
      y: y + 10,
      width: 80,
      height: 80,
    });
    page.drawText("NEXT STEP: DEPLOY FREE SENTINEL PILOT", {
      x: 60,
      y: y + 75,
      size: 10,
      font: fontBold,
      color: emeraldGreen,
    });
    page.drawText(
      "Verify these financial loss figures against live operational data at zero cost.",
      {
        x: 60,
        y: y + 58,
        size: 8.5,
        font: fontRegular,
        color: textLight,
      },
    );
    page.drawText(
      "Scan the QR code or click the link below to request a 2-4 week hardware pilot.",
      {
        x: 60,
        y: y + 44,
        size: 8.5,
        font: fontRegular,
        color: textMuted,
      },
    );
    page.drawText("URL: echolevel.vercel.app/sentinel/connect", {
      x: 60,
      y: y + 20,
      size: 9,
      font: fontBold,
      color: emeraldGreen,
    });

    // Footer
    page.drawLine({
      start: { x: 40, y: 45 },
      end: { x: 555, y: 45 },
      thickness: 0.5,
      color: rgb(0.85, 0.85, 0.85),
    });
    page.drawText(
      "EchoLevel Sentinel Limited · Industrial Telemetry & Fuel Verification Systems",
      {
        x: 40,
        y: 30,
        size: 8,
        font: fontBold,
        color: rgb(0.4, 0.4, 0.4),
      },
    );
    page.drawText(
      "Ibadan, Oyo State, Nigeria · echolevel.vercel.app/sentinel/connect",
      {
        x: 40,
        y: 18,
        size: 8,
        font: fontRegular,
        color: rgb(0.6, 0.6, 0.6),
      },
    );

    // ──────────────────────────────
    // Diagonal watermark (preview)
    // ──────────────────────────────
    page.drawText("CONFIDENTIAL PREVIEW — OFFICIAL COPY SENT TO EMAIL", {
      x: 70,
      y: 420,
      size: 14,
      font: fontBold,
      color: rgb(0.85, 0.2, 0.2),
      opacity: 0.28,
      rotate: { type: "degrees", angle: 32 },
    });

    const pdfBytes = await pdfDoc.save();
    const base64Pdf = btoa(String.fromCharCode(...pdfBytes));

    // ──────────────────────────────
    // Send official copy via Resend
    // ──────────────────────────────
    const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
    if (RESEND_API_KEY) {
      const resendRes = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${RESEND_API_KEY}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          from: "Sentinel Audits <onboarding@resend.dev>", // ← change to your verified domain
          to: ["launchbypatrick.webdev@gmail.com"],
          subject: `Sentinel Audit Report – ${organization} (${auditId})`,
          html: `
            <p>Hello,</p>
            <p>Your official high-resolution <strong>Fuel Loss Exposure Audit</strong> is attached.</p>
            <p>
              <strong>Organisation:</strong> ${organization}<br>
              <strong>Audit ID:</strong> ${auditId}<br>
              <strong>Estimated Annual Loss:</strong> ${formatNaira(totalAnnualLoss)}
            </p>
            <p>This is the full unwatermarked report. The in-app preview is intentionally limited.</p>
            <p>Best regards,<br>EchoLevel Sentinel Team</p>
          `,
          attachments: [
            {
              filename: `Sentinel_Audit_Report_${auditId}.pdf`,
              content: base64Pdf,
            },
          ],
        }),
      });

      if (!resendRes.ok) {
        const errData = await resendRes.json();
        console.error("Resend API Error:", errData);
        // We still return the preview even if email fails
      }
    } else {
      console.warn("RESEND_API_KEY not set – skipping email dispatch");
    }

    // ──────────────────────────────
    // Return base64 for Flutter gated preview
    // ──────────────────────────────
    return new Response(
      JSON.stringify({
        success: true,
        email,
        auditId,
        previewBase64: base64Pdf,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        error: (error as Error).message,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      },
    );
  }
});