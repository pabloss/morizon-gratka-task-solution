<?php

declare(strict_types=1);

namespace App\Controller;

use App\Form\Field\GenderType;
use App\Form\Type\SearchFormType;
use App\Form\Type\UserFormType;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Contracts\HttpClient\HttpClientInterface;

class UsersController extends AbstractController
{
    public function __construct(
        private readonly HttpClientInterface $phoenixClient,
    )
    {
    }

    #[Route('/users', name: 'users_list', methods: ['GET'])]
    public function index(Request $request): Response
    {
        if ($request->isXmlHttpRequest()) {
            $requestData = $request->query->all();

            $response = $this->phoenixClient->request('GET', 'users?' . $this->getQuery($requestData));

            $responseData = json_decode($response->getContent(), true, 512, JSON_THROW_ON_ERROR);

            return new JsonResponse($responseData);
        }

        return $this->render(
            'users/index.html.twig',
            [
                'form' => $this->createForm(SearchFormType::class),
            ]
        );
    }

    #[Route('/users/{id}', name: 'get_user', methods: ['GET'])]
    public function user(int $id): Response
    {
        $response = $this->phoenixClient->request('GET', 'users/' . $id);

        $responseData = json_decode($response->getContent(), true, 512, JSON_THROW_ON_ERROR);

        if (!isset($responseData['data']['gender'], $responseData['data']['birthdate'])) {
            $this->addFlash('error', 'No gender or birthdate found in response.');
            return $this->redirectToRoute('get_user', ['id' => $id]);
        }

        $responseData['data']['gender'] = GenderType::from($responseData['data']['gender']);
        $responseData['data']['birthdate'] = \DateTimeImmutable::createFromFormat('Y-m-d', $responseData['data']['birthdate']);

        return $this->render(
            'users/user.html.twig',
            [
                'form' => $this->createForm(
                    UserFormType::class,
                    $responseData['data']),
                [
                    'action' => $this->generateUrl('update_user', ['id' => $id]),
                ],
            ]
        );
    }

    #[Route('/users/{id}', name: 'update_user', methods: ['PUT'])]
    public function updateUser(int $id, Request $request): Response
    {
        $data = $this->cleanupEmptyValuesAndKeys($request->request->all()['user_form'], ['_token', 'id', 'submit']);

        $response = $this->phoenixClient->request(
            'PUT',
            'users/' . $id,
            [
                'json' => ['user' => $data],
            ]
        );

        if ($response->getStatusCode() !== 200) {
            $this->addFlash('error', sprintf('Response status code: %d',  $response->getStatusCode()));
            return $this->redirectToRoute('get_user', ['id' => $id]);
        }

        if ($response->getStatusCode() === 200) {
            $this->addFlash('success', sprintf('User %s was successfully updated', $id));
            return $this->redirectToRoute('users_list');
        }
    }

    #[Route('/users/{id}', name: 'delete_user', methods: ['DELETE'])]
    public function deleteUser(int $id): Response
    {
        $response = $this->phoenixClient->request(
            'DELETE',
            'users/' . $id,
        );
        if ($response->getStatusCode() !== 200) {
            $this->addFlash('error', sprintf('Response status code: %d',  $response->getStatusCode()));
        }

        if ($response->getStatusCode() === 200) {
            $this->addFlash('success', sprintf('User %s was successfully deleted', $id));
        }
        return $this->redirectToRoute('users_list');
    }


    private function getQuery(array $requestData): string
    {
        $data = $requestData['search_form'];
        $data['sort_by'] = $requestData['sort_by'] ?? null;
        $data['order'] = $requestData['order'] ?? null;

        $data = $this->cleanupEmptyValuesAndKeys($data, ['_token']);

        return $data ? http_build_query($data) : '';
    }

    private function cleanupEmptyValuesAndKeys(array $data, array $keysToDrop): array
    {
        return array_filter(
            $data,
            static fn($value, $key) => !empty($value) && !in_array($key, $keysToDrop, true),
            ARRAY_FILTER_USE_BOTH
        );
    }
}
