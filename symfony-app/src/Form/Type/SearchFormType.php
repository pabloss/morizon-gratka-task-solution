<?php
declare(strict_types=1);

namespace App\Form\Type;

use App\Form\Field\GenderType;
use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\Extension\Core\Type\ButtonType;
use Symfony\Component\Form\Extension\Core\Type\DateType;
use Symfony\Component\Form\Extension\Core\Type\EnumType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\Form\FormBuilderInterface;

class SearchFormType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options): void
    {
        $builder
            ->add('first_name', TextType::class, ['required' => false, 'label' => false, 'attr' => ['class' => 'form-control', 'placeholder' => 'Imię']])
            ->add('last_name', TextType::class, ['required' => false, 'label' => false, 'attr' => ['class' => 'form-control', 'placeholder' => 'Nazwisko']])
            ->add('gender', EnumType::class, ['class' => GenderType::class, 'required' => false, 'label' => 'Płeć', 'attr' => ['class' => 'form-control', 'placeholder' => 'Płeć']])
            ->add('birthdate_from', DateType::class, ['widget' => 'single_text', 'format' => 'yyyy-MM-dd', 'required' => false, 'label' => 'Data urodzenia "Od"', 'attr' => ['class' => 'form-control']])
            ->add('birthdate_to', DateType::class, ['widget' => 'single_text', 'format' => 'yyyy-MM-dd', 'required' => false, 'label' => 'Data urodzenia "Do"', 'attr' => ['class' => 'form-control']])
            ->add('search', ButtonType::class, ['label' => 'Szukaj', 'attr' => ['class' => 'btn btn-primary', 'type' => 'submit']])
        ;
    }
}