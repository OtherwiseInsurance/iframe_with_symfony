<?php
namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class PartnerController extends AbstractController
{
    /**
     * @Route("/{partner}", name="Partner iFrame")
     */
    public function showIframe(Request $request, string $partner): Response
    {
        $iFrameUrl = $this->getParameter("app.otherwiseUrl")."/partenaire/".$partner;        
            
        if ($request->query->get("embed")) {
            $iFrameUrl=urldecode($request->query->get("embed"));
        }

        return $this->render("iFrame.html.twig", [
            "iFrameUrl" => $iFrameUrl,
        ]);
    }
}
